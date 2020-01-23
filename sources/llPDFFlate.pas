{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFFlate;

{$i pdf.inc}

interface

{$IFDEF win32}

uses
{$ifndef USENAMESPACE}
  SysUtils, Classes,
{$else}
  System.SysUtils, System.Classes,
{$endif}
  llPDFTypes;

type

  TAlloc = function ( AppData: Pointer; Items, Size: Integer ): Pointer;
  TFree = procedure ( AppData, Block: Pointer );

  TZStreamRec = packed record
    next_in: PANSIChar;
    avail_in: Integer;
    total_in: Integer;

    next_out: PANSIChar;
    avail_out: Integer;
    total_out: Integer;

    msg: PANSIChar;
    internal: Pointer;

    zalloc: TAlloc;
    zfree: TFree;
    AppData: Pointer;

    data_type: Integer;
    adler: Integer;
    reserved: Integer;
  end;

  TCustomZlibStream = class ( TStream )
  private
    FStrm: TStream;
    FStrmPos: Integer;
    FOnProgress: TNotifyEvent;
    FZRec: TZStreamRec;
    FBuffer: array [ Word ] of ANSIChar;
  protected
    procedure Progress ( Sender: TObject ); dynamic;
    property OnProgress: TNotifyEvent read FOnProgress write FOnProgress;
    constructor Create ( Strm: TStream );
  end;

  TCompressionLevel = ( clNone, clFastest, clDefault, clMax );

  TCompressionStream = class ( TCustomZlibStream )
  private
    function GetCompressionRate: Single;
  public
    constructor Create ( CompressionLevel: TCompressionLevel; Dest: TStream );
    destructor Destroy; override;
    function Read ( var Buffer; Count: Longint ): Longint; override;
    function Write ( const Buffer; Count: Longint ): Longint; override;
    function Seek ( Offset: Longint; Origin: Word ): Longint; override;
    property CompressionRate: Single read GetCompressionRate;
    property OnProgress;
  end;

{$ENDIF}

implementation
{$IFDEF win32}
uses llPDFResources;


type
  EZlibError = class ( Exception );
  ECompressionError = class ( EZlibError );
const
  Z_NO_FLUSH = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH = 2;
  Z_FULL_FLUSH = 3;
  Z_FINISH = 4;

  Z_OK = 0;
  Z_STREAM_END = 1;
  Z_NEED_DICT = 2;
  Z_ERRNO = ( -1 );
  Z_STREAM_ERROR = ( -2 );
  Z_DATA_ERROR = ( -3 );
  Z_MEM_ERROR = ( -4 );
  Z_BUF_ERROR = ( -5 );
  Z_VERSION_ERROR = ( -6 );

  Z_NO_COMPRESSION = 0;
  Z_BEST_SPEED = 1;
  Z_BEST_COMPRESSION = 9;
  Z_DEFAULT_COMPRESSION = ( -1 );

  Z_FILTERED = 1;
  Z_HUFFMAN_ONLY = 2;
  Z_DEFAULT_STRATEGY = 0;

  Z_BINARY = 0;
  Z_ASCII = 1;
  Z_UNKNOWN = 2;

  Z_DEFLATED = 8;

{$L obj\deflate.obj}
{$L obj\inflate.obj}
{$L obj\inftrees.obj}
{$L obj\trees.obj}
{$L obj\adler32.obj}
{$L obj\infblock.obj}
{$L obj\infcodes.obj}
{$L obj\infutil.obj}
{$L obj\inffast.obj}

procedure _tr_init; external;
procedure _tr_tally; external;
procedure _tr_flush_block; external;
procedure _tr_align; external;
procedure _tr_stored_block; external;
procedure adler32; external;
procedure inflate_blocks_new; external;
procedure inflate_blocks; external;
procedure inflate_blocks_reset; external;
procedure inflate_blocks_free; external;
procedure inflate_set_dictionary; external;
procedure inflate_trees_bits; external;
procedure inflate_trees_dynamic; external;
procedure inflate_trees_fixed; external;
procedure inflate_trees_free; external;
procedure inflate_codes_new; external;
procedure inflate_codes; external;
procedure inflate_codes_free; external;
procedure _inflate_mask; external;
procedure inflate_flush; external;
procedure inflate_fast; external;

procedure _memset ( P: Pointer; B: Byte; count: Integer ); cdecl;
begin
  FillChar ( P^, count, B );
end;

procedure _memcpy ( dest, source: Pointer; count: Integer ); cdecl;
begin
  Move ( source^, dest^, count );
end;

const
  zlib_Version = '1.0.4';

// deflate compresses data
function deflateInit_ ( var strm: TZStreamRec; level: Integer; version: PANSIChar;
  recsize: Integer ): Integer; external;
function deflate ( var strm: TZStreamRec; flush: Integer ): Integer; external;
function deflateEnd ( var strm: TZStreamRec ): Integer; external;

function zlibAllocMem ( AppData: Pointer; Items, Size: Integer ): Pointer;
begin
  GetMem ( Result, Items * Size );
end;

procedure zlibFreeMem ( AppData, Block: Pointer );
begin
  FreeMem ( Block );
end;

function zlibCheck ( code: Integer ): Integer;
begin
  Result := code;
  if code < 0 then
    raise EZlibError.Create ( SCompressionError ); //!!
end;

function CCheck ( code: Integer ): Integer;
begin
  Result := code;
  if code < 0 then
    raise ECompressionError.Create ( SCompressionError ); //!!
end;

procedure CompressBuf ( const InBuf: Pointer; InBytes: Integer;
  out OutBuf: Pointer; out OutBytes: Integer );
var
  strm: TZStreamRec;
  P: Pointer;
begin
  FillChar ( strm, sizeof ( strm ), 0 );
  strm.zalloc := zlibAllocMem;
  strm.zfree := zlibFreeMem;
  OutBytes := ( ( InBytes + ( InBytes div 10 ) + 12 ) + 255 ) and not 255;
  GetMem ( OutBuf, OutBytes );
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := OutBytes;
    CCheck ( deflateInit_ ( strm, Z_BEST_COMPRESSION, zlib_version, sizeof ( strm ) ) );
    try
      while CCheck ( deflate ( strm, Z_FINISH ) ) <> Z_STREAM_END do
      begin
        P := OutBuf;
        Inc ( OutBytes, 256 );
        ReallocMem ( OutBuf, OutBytes );
        strm.next_out := PANSIChar ( Integer ( OutBuf ) + ( Integer ( strm.next_out ) - Integer ( P ) ) );
        strm.avail_out := 256;
      end;
    finally
      CCheck ( deflateEnd ( strm ) );
    end;
    ReallocMem ( OutBuf, strm.total_out );
    OutBytes := strm.total_out;
  except
    FreeMem ( OutBuf );
    raise
  end;
end;

// TCustomZlibStream

constructor TCustomZLibStream.Create ( Strm: TStream );
begin
  inherited Create;
  FStrm := Strm;
  FStrmPos := Strm.Position;
  FZRec.zalloc := zlibAllocMem;
  FZRec.zfree := zlibFreeMem;
end;

procedure TCustomZLibStream.Progress ( Sender: TObject );
begin
  if Assigned ( FOnProgress ) then
    FOnProgress ( Sender );
end;


// TCompressionStream

constructor TCompressionStream.Create ( CompressionLevel: TCompressionLevel;
  Dest: TStream );
const
  Levels: array [ TCompressionLevel ] of ShortInt =
  ( Z_NO_COMPRESSION, Z_BEST_SPEED, Z_DEFAULT_COMPRESSION, Z_BEST_COMPRESSION );
begin
  inherited Create ( Dest );
  FZRec.next_out := FBuffer;
  FZRec.avail_out := sizeof ( FBuffer );
  CCheck ( deflateInit_ ( FZRec, Levels [ CompressionLevel ], zlib_version, sizeof ( FZRec ) ) );
end;

destructor TCompressionStream.Destroy;
begin
  FZRec.next_in := nil;
  FZRec.avail_in := 0;
  try
    if FStrm.Position <> FStrmPos then
      FStrm.Position := FStrmPos;
    while ( CCheck ( deflate ( FZRec, Z_FINISH ) ) <> Z_STREAM_END )
      and ( FZRec.avail_out = 0 ) do
    begin
      FStrm.WriteBuffer ( FBuffer, sizeof ( FBuffer ) );
      FZRec.next_out := FBuffer;
      FZRec.avail_out := sizeof ( FBuffer );
    end;
    if FZRec.avail_out < sizeof ( FBuffer ) then
      FStrm.WriteBuffer ( FBuffer, sizeof ( FBuffer ) - FZRec.avail_out );
  finally
    deflateEnd ( FZRec );
  end;
  inherited Destroy;
end;

function TCompressionStream.Read ( var Buffer; Count: Longint ): Longint;
begin
  raise ECompressionError.Create ( SInvalidStreamOperation );
end;

function TCompressionStream.Write ( const Buffer; Count: Longint ): Longint;
begin
  FZRec.next_in := @Buffer;
  FZRec.avail_in := Count;
  if FStrm.Position <> FStrmPos then
    FStrm.Position := FStrmPos;
  while ( FZRec.avail_in > 0 ) do
  begin
    CCheck ( deflate ( FZRec, 0 ) );
    if FZRec.avail_out = 0 then
    begin
      FStrm.WriteBuffer ( FBuffer, sizeof ( FBuffer ) );
      FZRec.next_out := FBuffer;
      FZRec.avail_out := sizeof ( FBuffer );
      FStrmPos := FStrm.Position;
      Progress ( Self );
    end;
  end;
  Result := Count;
end;

function TCompressionStream.Seek ( Offset: Longint; Origin: Word ): Longint;
begin
  if ( Offset = 0 ) and ( Origin = soFromCurrent ) then
    Result := FZRec.total_in
  else
    raise ECompressionError.Create ( SInvalidStreamOperation );
end;

function TCompressionStream.GetCompressionRate: Single;
begin
  if FZRec.total_in = 0 then
    Result := 0
  else
    Result := ( 1.0 - ( FZRec.total_out / FZRec.total_in ) ) * 100.0;
end;

{$ENDIF}

end.

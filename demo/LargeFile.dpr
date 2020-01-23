program LargeFile;
{$i demo.inc}

var
  MyPDF: TPDFDocument;
  I: Integer;
  X, Y: Integer;
  St: string;
  line: integer;
  ss: string;
  RowCount, ColumnCount: integer;
  RowHeight, ColumnWidth: integer;
  col, row: integer;
  C: TDateTime;
  h, m, sss, ms: Word;
begin
	C := Time;
    MyPDF := TPDFDocument.Create(nil);
    try
      MyPDF.FileName := 'Data\PDFFiles\LargeFile.pdf';
      MyPDF.DocumentInfo.Title := 'llPDFLib 6.x Demo [Large File]';
      MyPDF.AutoLaunch := True;
      MyPDF.Compression := ctFlate;
      st := '';
      MyPDF.OnePass := True;
      MyPDF.BeginDoc;
    { create pages }
      for I := 1 to 1000 do
      begin
        if I <> 1 then MyPDF.NewPage;
        with MyPDF.CurrentPage do
        begin
          SetActiveFont('Verdana', [], 8);
        { some lines of text }
          for line := 1 to 35 do
          begin
            ss := IntToStr(line) + 'Test string Test String';
            ss := ss + ' Integer Boolean Real';
            ss := ss + IntToStr(line);
            ss := ss + IntToStr(random(10000));
            ss := ss + 'string Cardinal';
            TextOut(15, 40 + (20 * line), 0, ss);
          end;
       { rectangles over page }
          RowCount := 50;
          ColumnCount := 20;
          RowHeight := (Height - 5) div RowCount;
          ColumnWidth := (Width - 5) div ColumnCount;
          for row := 1 to RowCount - 2 do
          begin
            for col := 1 to ColumnCount - 2 do
            begin
              y := row * RowHeight;
              x := col * ColumnWidth;
              GStateSave;
              NewPath;
              Rectangle(x, y, x + ColumnWidth, y + RowHeight);
              ClosePath;
              Stroke;
            end;
          end;
          ClosePath;
        end;
      { print progress on console }
        ss := 'Prepare page ' + IntToStr(I);
        write(ss + #13);
      end;
      MyPDF.EndDoc;
      Writeln;
      writeln('OK');
    finally
      MyPDF.Free;
    end;
    C := Time - C;
    DecodeTime(C, h, m, sss, ms);
    Writeln('Document was created in ', h, ' hour ', m, ' min ', sss, ' sec ', ms, ' ms.');
end.


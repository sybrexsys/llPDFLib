{**************************************************
                                                  
                   llPDFLib                       
      Version  6.4.0.1389,   09.07.2016            
     Copyright (c) 2002-2016  Sybrex Systems      
     Copyright (c) 2002-2016  Vadim M. Shakun
               All rights reserved                
           mailto:em-info@sybrex.com              
                                                  
**************************************************}

unit llPDFResources;
{$i pdf.inc}
interface

resourcestring
  SCCITTCompressionWorkOnlyForBitma = 'CCITT compression work only for bitmap';
  SCCITTProcedureNotInited = 'CCITT Procedure not inited';
  SExportValuePresent = 'In this radiogroup such exportvalue present';
  SCannotSetEmptyExportValue = 'Cannot set empty export value for radiobutton';
  SNoSuchRadiogroupInThisDocument = 'No such radiogroup in this document';
  SCannotSetNegativeSize = 'Cannot set negative size';
  SCannotUseSuchCharset = 'Cannot use such charset';
  SCannotChangePageInOnePassMode = 'Cannot change page in one pass mode';
  SCannotAccessToPageInOnePassMode = 'Cannot access to page in One Pass mode';
  SCannotReceiveDataForFont = 'Cannot receive data for font ';
  SNotValidTrueTypeFont = 'Not valid true type font.';
  SFormAlreadyExists = 'Form already exists.';
  SPDFControlNamed = 'PDFControl Named ';
  SCannotCompressNotMonochromeImageViaCCITT = 'Cannot compress not monochrome image via CCITT';
  SFileNameCannotBeEmpty = 'FileName cannot be empty';
  SURLCannotBeEmpty = 'URL cannot be empty';
  STopOffsetCannotBeNegative = 'Top Offset cannot be negative';
  SPageIndexCannotBeNegative = 'PageIndex cannot be negative';
  SJavaScriptCannotBeEmpty = 'JavaScript cannot be empty';
  SAnnotationMustHaveTPDFPageAsOwner = 'Annotation must have TPDFPage as owner';
  SMetafileNotLoaded = 'Metafile not loaded';
  SOutlineNodeMustHaveOwner = 'Outline node must have owner';
  SImageWithSuchIndexNotCreatedYetForThisDocument = 'Image with such index not created yet for this document';
  SWatermarkCannotHaveThumbnail = 'Watermark cannot have thumbnail';
  SCannotCreateURLToWatermark = 'Cannot create URL to watermark';
  SCanvasForThisPageNotCreatedOrWasRemoved = 'Canvas for this page not created or was removed.';
  SWaterMarkWithSuchIndexNotCreatedYetForThisDocument = 'WaterMark with such index not created yet for this document';
  SWatermarkCannotHaveWatermark = 'Watermark cannot have watermark';
  SCanvasForThisPageAlreadyCreated = 'Canvas for this page already created';
  SPageInProgress = 'Page in progress';
  SCannotCreateLinkToPageToWatermark = 'Cannot create "Link To Page" to watermark';
  SCannotCreateAnnotationToWatermark = 'Cannot create annotation to watermark';
  SActiveFontNotSetting = 'Active font not setting';
  SAvailableForTrueTypeFontOnly = 'Available for TrueType font only';
  SOutOfRange = 'Out of range';
  STextObjectNotInited = 'Text object not inited';
  STextObjectInited = 'Text object inited';
  SCannotBeginTextObjectTwice = 'Cannot begin text object twice';
  SGenerationPDFFileNotActivated = 'Generation PDF file not activated';
  SOnlyOneDigitalSignatureAvaiable = 'Only One Digital SignatureAvaiable';
  SGenerationPDFFileInProgress = 'Generation PDF file in progress';
  SBitmapNotMonochrome = 'Bitmap not monochrome';
  SInvalidStreamOperation = 'Invalid stream operation';
  SCompressionError = 'Compression error';
  SRC4InvalidKeyLength = 'RC4: Invalid key length';
  SFileOpenError = 'Couldn''t open file';
  SFileSaveError = 'Couldn''t save file';
  SFileReadError = 'File read error';
  SFileCorrupt = 'File corrupt';
  SUnknownVersion = 'Unknown version or file corrupt';
  SMaskImageCannotHaveMask = 'Mask Image cannot have mask';
  SNotValidImage = 'Not valid image.';
  SUnknowMaskImageOutOfBound = 'Unknow Mask Image. Out of bound.';
  SMaskImageNotMarkedAsMaskImage = 'Mask Image not marked as "Mask Image".';
  SCreateMaskAvailableOnlyForBitmapImages = 'Create Mask available only for bitmap images';
  SCCITTCompressionWorkOnlyForBitmap = 'CCITT compression work only for bitmap.';
  SCannotChangeStream = 'Cannot change stream.';
  SInvalidActionArgument ='Invalid Action argument. Must be TPDFAction';
  SPDFACompatible ='Cannot set this value for PDF/A document.';
  SSecutityCompatible ='Cannot set this value for encrypted PDF document.';
  SRGBICCStreamError = 'RGB ICC not set. Cannot create PDF/A document.';
  SCMYKICCStreamError = 'CMYK ICC not set. Cannot create PDF/A document.';
  SBCDSaveRestoreStateError = 'Cannot save or restore state in BCD section.';
  SInvalidEncryptionAlgorithm = 'Invalid Encryption Algorithm.';
  SInvalidEncryptedData = 'Invalid Encrypted Data.';
  SInvalidEncryptionAlgorithmVersio = 'Invalid Encryption Algorithm Version.';
  SNotFoundPairCertificateAndPrivat = 'Not found pair certificate and private key';
  SCertificatesNotFoundInPfxDocumen = 'Certificates not found in pfx document';
  SPrivateKeyNotFoundInPfxDocument = 'Private key not found in pfx document';
  SAuthenticatedSafeCannotLoaded = 'AuthenticatedSafe cannot loaded.';
  SEncryptedDocument = 'Encrypted document';
  SMacDataInformationNotFound = 'MacData information not found.';
  SPKCS7InformationNotFound = 'PKCS#7 information not found.';
  SInvalidVersionOfDocument = 'Invalid version of document.';
  SUnknownStructure = 'Unknown structure.';
  SASN1SequenceNotFound = 'ASN1 sequence not found.';
  SAlgorithmNotSupported = 'Algorithm not supported';
  SUnknownMacDataStructure = 'Unknown MacData structure.';
  SUnknownDigestStructure = 'Unknown digest structure.';
  SUnsupportedDigestAlgorithm = 'Unsupported digest algorithm.';
  SUnsupportedDocument = 'Unsupported document.';
  SUnsupportedYetDocument = 'Unsupported yet document.';
  SInvalidASN1DocumentInvalidTagWas = 'Invalid ASN.1 document. Invalid tag was found';
  SInvalidASN1DocumentCannotCalcula = 'Invalid ASN.1 document. Cannot calculate length or tag.';
  SInvalidASN1DocumentVeryLargeLeng = 'Invalid ASN.1 document. Very large length.';
  SInvalidASN1DocumentVeryLargeTag = 'Invalid ASN.1 document. Very large Tag';
  SInvalidASN1DocumentTagBooleanLen = 'Invalid ASN.1 document. Tag Boolean length not equal to 1';
  SOutOfBounds = 'Out of Bounds';
  SInvalidNameOfCertificate = 'Invalid name of certificate';
  SUnsupportedAlgorithm = 'Unsupported algorithm';
  SInvalidSerialNumberOfCertificate = 'Invalid serial number of certificate';
  SInvalidCertificate = 'Invalid certificate';
  SInvalidPrivateKey = 'Invalid private key';
  SCannotChangeValue = 'Cannot change value for this class';
  SSmallModulusSize = 'Small modulus size for Digital Signature';
  SRSAError = 'RSA Error';

implementation
  



end.






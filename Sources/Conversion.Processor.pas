unit Conversion.Processor;

interface

uses
  Conversion.Processor.Interfaces,
  System.SysUtils;

type
  TConversionProcessor = class(TInterfacedObject, IConversionProcessor)
  private
    FTargetEncoding: TEncodingTarget;

    function LoadStringFromFile(const FileName: string): RawByteString;
    procedure SaveStringToFile(const FileContent: RawByteString; const FileName: string);
  public
    procedure AfterConstruction; override;

    function UseTargetEncoding(const Encoding: TEncodingTarget): IConversionProcessor;
    procedure Convert(const FileName: string; const CodePage: Integer; const Progress: TProc<string>);
  end;

  TConversionHelper = class
  public
    class function DetectEncoding(const FileName: string): TFileEncoding;
  end;

implementation

uses
  System.Classes,
  System.IOUtils;

{ TConversionProcessor }

function TConversionProcessor.UseTargetEncoding(const Encoding: TEncodingTarget): IConversionProcessor;
begin
  Result := Self;
  FTargetEncoding := Encoding;
end;

procedure TConversionProcessor.AfterConstruction;
begin
  inherited;
  FTargetEncoding := TEncodingTarget.UTF8;
end;

procedure TConversionProcessor.Convert(const FileName: string; const CodePage: Integer; const Progress: TProc<string>);
begin
  var FileEncoding := TConversionHelper.DetectEncoding(FileName);
  var IsUnicode := (FileEncoding <> TFileEncoding.ANSI);

  if IsUnicode then
  begin
    Progress(Format('"%s": File is already in Unicode', [FileName]));
    Exit;
  end;

  Progress(Format('"%s": Converting file to Unicode', [FileName]));

  var FileContent := LoadStringFromFile(FileName);

  SetCodePage(FileContent, CodePage, False);
  SetCodePage(FileContent, FTargetEncoding.CodePage, True);

  var BackupFileName := FileName + '.bak';
  if TFile.Exists(BackupFileName) then
    TFile.Delete(BackupFileName);

  TFile.Move(FileName, BackupFileName);

  SaveStringToFile(FileContent, FileName);
end;

function TConversionProcessor.LoadStringFromFile(const FileName: string): RawByteString;
begin
  var fs := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Result, fs.Size);

    if fs.Size > 0 then
      fs.Read(Result[1], Length(Result));
  finally
    fs.Free;
  end;
end;

procedure TConversionProcessor.SaveStringToFile(const FileContent: RawByteString; const FileName: string);
begin
  if FileContent = '' then
    Exit;

  var ContentWithBOM := RawByteString(FTargetEncoding.BOM) + FileContent;
  var fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.Write(ContentWithBOM[1], Length(ContentWithBOM));
  finally
    fs.Free;
  end;
end;

{ TConversionHelper }

class function TConversionHelper.DetectEncoding(const FileName: string): TFileEncoding;
var
  BOM: array[0..2] of Byte;
begin
  Result := TFileEncoding.ANSI;

  var FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    var BytesRead := FileStream.Read(BOM, SizeOf(BOM));
    var HasReadBOM := (BytesRead >= 2);

    if not HasReadBOM then
      Exit;

    if (BOM[0] = $FF) and (BOM[1] = $FE) then
      Result := TFileEncoding.UTF16LE
    else if (BOM[0] = $FE) and (BOM[1] = $FF) then
      Result := TFileEncoding.UTF16BE
    else if (BOM[0] = $EF) and (BOM[1] = $BB) and (BOM[2] = $BF) then
      Result := TFileEncoding.UTF8;

  finally
    FileStream.Free;
  end;
end;

end.

unit Conversion.Processor.Tests;

interface

uses
  DUnitX.TestFramework,
  Conversion.Processor.Interfaces;

type
  [TestFixture]
  TConversionProcessorTests = class
  private
    FTestFileFolder: string;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [TestCase('ANSI 1250', 'TestFile.Codepage1250.txt,ANSI')]
    [TestCase('ANSI 1252', 'TestFile.Codepage1250.txt,ANSI')]
    [TestCase('UTF8', 'TestFile.UTF8.Delphi.pas,UTF8')]
    [TestCase('UTF8', 'TestFile.UTF8.txt,UTF8')]
    [TestCase('UTF16LE', 'TestFile.UTF16LE.txt,UTF16LE')]
    [TestCase('UTF16BE', 'TestFile.UTF16BE.txt,UTF16BE')]
    procedure CheckEncoding(const FileName: string; const ExpectedEncoding: TFileEncoding);

    [TestCase('ANSI 1252', 'TestFile.Codepage1250.txt,1250,Converted')]
    [TestCase('UTF8', 'TestFile.UTF8.txt,1252,AlreadyConverted')]
    procedure ConvertFile(const FileName: string; const CodePage: Integer; const ExpectedResult: TConversionResult);
  end;

implementation

uses
  Conversion.Processor,
  System.IOUtils,
  System.SysUtils;

procedure TConversionProcessorTests.CheckEncoding(const FileName: string; const ExpectedEncoding: TFileEncoding);
begin
  var FilePath := TPath.Combine(FTestFileFolder, FileName);
  var FileEncoding := TConversionHelper.DetectEncoding(FilePath);

  Assert.AreEqual(ExpectedEncoding, FileEncoding);
end;

procedure TConversionProcessorTests.ConvertFile(const FileName: string; const CodePage: Integer; const ExpectedResult: TConversionResult);
begin
  var FilePath := TPath.Combine(FTestFileFolder, FileName);
  var FileCopyPath := Format('%s.testcopy', [FileName]);

  TFile.Copy(FilePath, FileCopyPath);
  try
    var Processor: IConversionProcessor := TConversionProcessor.Create;
    var EmptyLogging: TProc<string> := procedure(Msg: string)
                                       begin
                                       end;

    var ConversionResult := Processor
                              .UseTargetEncoding(TEncodingTarget.UTF8)
                              .Convert(FileCopyPath, CodePage, EmptyLogging);

    Assert.AreEqual(ExpectedResult, ConversionResult);

    if (ConversionResult = TConversionResult.Converted) then
    begin
      var SecondConversionResult := Processor
                                      .UseTargetEncoding(TEncodingTarget.UTF8)
                                      .Convert(FileCopyPath, CodePage, EmptyLogging);

      Assert.AreEqual(TConversionResult.AlreadyConverted, SecondConversionResult);
    end;

  finally
    TFile.Delete(FileCopyPath);
  end;
end;

procedure TConversionProcessorTests.Setup;
begin
  FTestFileFolder := '..\..\TestFiles\';
end;

procedure TConversionProcessorTests.TearDown;
begin
end;

end.

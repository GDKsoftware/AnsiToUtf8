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
  end;

implementation

uses
  Conversion.Processor,
  System.IOUtils;

procedure TConversionProcessorTests.CheckEncoding(const FileName: string; const ExpectedEncoding: TFileEncoding);
begin
  var FilePath := TPath.Combine(FTestFileFolder, FileName);
  var FileEncoding := TConversionHelper.DetectEncoding(FilePath);

  Assert.AreEqual(ExpectedEncoding, FileEncoding);
end;

procedure TConversionProcessorTests.Setup;
begin
  FTestFileFolder := '..\..\TestFiles\';
end;

procedure TConversionProcessorTests.TearDown;
begin
end;

end.

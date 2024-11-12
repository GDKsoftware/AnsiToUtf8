unit Conversion.Processor.Interfaces;

interface

uses
  System.SysUtils;

type
  {$SCOPEDENUMS ON}
  TFileEncoding = (ANSI, UTF16LE, UTF16BE, UTF8);
  TEncodingTarget = (UTF8, UTF16LE, UTF16BE);
  {$SCOPEDENUMS OFF}

  IConversionProcessor = interface
    ['{1FC63B56-34BB-410B-B6B8-A049B9FE74E3}']

    function UseTargetEncoding(const Encoding: TEncodingTarget): IConversionProcessor;
    procedure Convert(const FileName: string; const CodePage: Integer; const Progress: TProc<string>);
  end;

  TEncodingTargetHelper = record helper for TEncodingTarget
    function CodePage: Integer;
    function BOM: string;
  end;

implementation

{ TEncodingTargetHelper }

function TEncodingTargetHelper.CodePage: Integer;
begin
  case Self of
    TEncodingTarget.UTF8: Result := 65001;
    TEncodingTarget.UTF16LE: Result := 1200;
    TEncodingTarget.UTF16BE: Result := 1201;
  else
    raise ENotSupportedException.CreateFmt('Encoding target %d is not supported. Codepage unknown.', [Ord(Self)]);
  end;
end;

function TEncodingTargetHelper.BOM: string;
begin
  case Self of
    TEncodingTarget.UTF8: Result := #$EF#$BB#$BF;
    TEncodingTarget.UTF16LE: Result := #$FF#$FE;
    TEncodingTarget.UTF16BE: Result := #$FE#$FF;
  else
    raise ENotSupportedException.CreateFmt('Encoding target %d is not supported. BOM unknown.', [Ord(Self)]);
  end;
end;

end.

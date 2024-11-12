program AnsiToUtf8;
// Disable the "new" RTTI
{$WEAKLINKRTTI ON}
{$IF DECLARED(TVisibilityClasses)}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Windows,
  Conversion.Processor in 'Sources\Conversion.Processor.pas',
  Conversion.Processor.Interfaces in 'Sources\Conversion.Processor.Interfaces.pas';

begin
  try
    if ParamCount = 0 then begin
      Writeln('ANSI to UTF-8 file converter.');
      Writeln('Usage: ', ExtractFileName(ParamStr(0)), ' <filename or folder>');
      Writeln('Options:');
      Writeln('  -cp <codepage>: Define an ANSI codepage for the file (default 1251).');
      Writeln('  -subdirs: Include subdirectories when converting a folder.');
      Exit;
    end;

    var FileParam := ParamStr(1);
    var CodePage := 1251;

    var CodePageParam: string;
    if FindCmdLineSwitch('cp', CodePageParam) then
      CodePage := StrToInt(CodePageParam);

    Writeln(Format('Started ANSI (codepage %d) to UTF-8 conversion', [CodePage]));

    var Processor: IConversionProcessor := TConversionProcessor.Create;
    Processor
      .UseTargetEncoding(TEncodingTarget.UTF8);

    var IsDirectory := False;
    if TDirectory.Exists(FileParam) then
      IsDirectory := True;

    var SearchOption := TSearchOption.soTopDirectoryOnly;
    if FindCmdLineSwitch('subdirs', CodePageParam) then
      SearchOption := TSearchOption.soAllDirectories;

    var Files: TArray<string> := [];
    if IsDirectory then
      Files := TDirectory.GetFiles(FileParam, '*.pas', SearchOption)
    else
      Files := [FileParam];

    for var FileName in Files do
    begin
      try
        Processor
          .Convert(FileName, CodePage,
            procedure(ProgressMsg: string)
            begin
              Writeln(ProgressMsg);
            end);
      except
        on E: Exception do
          Writeln(Format('> ERRROR: [%s] %s', [E.ClassName, E.Message]));
      end;
    end;

    Writeln('Conversion finished');
  except
    on E: Exception do
      Writeln(Format('ERRROR: [%s] %s', [E.ClassName, E.Message]));
  end;
end.

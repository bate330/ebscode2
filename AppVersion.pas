unit AppVersion;
interface

type
  TAppCompile = (acAlpha, acBeta, acRelease);

  TAppVersion = record
    Major: UInt32;
    Minor: UInt32;
    Release: UInt32;
    Build: UInt32;
    Compile: TAppCompile;
    function AsString: string;
  end;

implementation uses SysUtils;

{ TApplicationVersion }

function TAppVersion.AsString: string;
begin
  Result := IntToStr(Major) + '.' + IntToStr(Minor) + '.' + IntToStr(Release) +
    '.' + IntToStr(Build);

  case Compile of
    acAlpha:    Result := Result + 'a';
    acBeta:     Result := Result + 'b';
  end;

end;

end.

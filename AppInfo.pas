unit AppInfo;
interface uses AppVersion;

//==============================================================================
type
  TAppInfo = class
    class function Name: string;
    class function Version: TAppVersion;
    class function Directory: string;
    class function NameVersion: string; virtual;

  end;

//==============================================================================
implementation uses SysUtils, Forms;

//==============================================================================
const
  APP_NAME = 'Dot2DotPrint';
  APP_VER_MAJOR = 1;
  APP_VER_MINOR = 0;
  APP_VER_RELEASE = 1;
  APP_VER_BUILD = 7;
  APP_VER_COMPILE = acBeta;

//==============================================================================
{ TAppInfo }

class function TAppInfo.Name: string;
begin
  Result := APP_NAME;
end;

//------------------------------------------------------------------------------
class function TAppInfo.Directory: string;
begin
  Result := ExtractFileDir(Application.ExeName);
end;

//------------------------------------------------------------------------------
class function TAppInfo.NameVersion: string;
begin
  Result := Name + ' ' + Version.AsString;
end;

//------------------------------------------------------------------------------
class function TAppInfo.Version: TAppVersion;
begin
  Result.Major := APP_VER_MAJOR;
  Result.Minor := APP_VER_MINOR;
  Result.Release := APP_VER_RELEASE;
  Result.Build := APP_VER_BUILD;
  Result.Compile := APP_VER_COMPILE;
end;

end.

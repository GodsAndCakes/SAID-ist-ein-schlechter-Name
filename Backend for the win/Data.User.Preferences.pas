unit Data.User.Preferences;

interface

uses
  System.SysUtils,
  System.Classes;

type
  IPreferences = interface
    ['{46F1A60D-634F-4F0F-AB8B-6A13FBE15A14}']
    function GetFavourable(const AKeyword: String): Boolean;
    function GetUnfavourable(const AKeyword: String): Boolean;
    property Favourable[const AKeyword: String]: Boolean read GetFavourable;
    property Unfavourable[const AKeywords: String]: Boolean read GetUnfavourable;
    function GetAllPreferences: TStringList;
  end;

implementation

end.

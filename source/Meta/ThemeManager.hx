package;

class ThemeManager
{
    public static var ThemeWasteland : Int = 1;
    public static var ThemeOcean : Int = 2;
    public static var ThemeCity : Int = 3;
    public static var ThemeTech : Int = 4;

    public static var SideA : Int = 0;
    public static var SideB : Int = 1;

    public static var Backgrounds : Array<Array<String>>;

    public static function Init()
    {
        Backgrounds = [];
        Backgrounds[ThemeWasteland] = ["bgThemeWastelandA", "bgThemeWastelandB"];
    }

    public static function Get(Theme : Int, Side : Int) : String
    {
        if (isValid(Theme, Side))
            return "assets/backgrounds/" + Backgrounds[Theme][Side] + ".png";
        else
            return null;
    }

    static function isValid(Theme : Int, Side : Int)
    {
        return Theme == ThemeWasteland && Side >= 0 && Side < 2;
    }
}

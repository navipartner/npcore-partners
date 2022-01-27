interface "NPR ISubMenu"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure AddMenuButton(MenuButton: Codeunit "NPR POS Menu Button");
}

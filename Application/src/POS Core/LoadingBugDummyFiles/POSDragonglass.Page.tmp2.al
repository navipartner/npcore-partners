page 6185113 "NPR (Dragonglass) Tmp2"
{
    Extensible = False;
    Caption = '[Testing purposes only] : Dummy ControllAddin';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR DummyControlAddIn")
            {
                ApplicationArea = NPRRetail;
            }
        }
    }

}

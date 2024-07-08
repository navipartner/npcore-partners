page 6014527 "NPR TouchScreen: G/L Accounts"
{
    Extensible = False;
    Caption = 'Touch Screen - Lookup G/L Account';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "G/L Account";
    SourceTableView = SORTING("Search Name") ORDER(Ascending);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
        GLAccount: Record "G/L Account";
    begin
        if Rec.MarkedOnly() then
            exit;
        GLAccount := Rec;
        AuxGLAccount.SetCurrentKey("Retail Payment");
        AuxGLAccount.SetRange("Retail Payment", true);
        if AuxGLAccount.FindSet() then
            repeat
                if Rec.Get(AuxGLAccount."No.") and not Rec.Blocked then
                    Rec.Mark(true);
            until AuxGLAccount.Next() = 0;
        Rec.MarkedOnly(true);
        Rec := GLAccount;
        if Rec.find('=><') then;
    end;
}

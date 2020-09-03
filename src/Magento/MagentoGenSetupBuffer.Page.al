page 6151400 "NPR Magento Gen. Setup Buffer"
{
    // MAG1.17/MH/20150617  CASE 215910 Object created - Displays Generic Xml Setup stored in BLOB as Tree structure
    // MAG1.17/TR/20150619  CASE 210183 SendKeys called in order to exspand tree structure.
    // MAG1.21/MHA/20151104 CASE 223835 Added function SetSourceTable();
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA/20170105  CASE 262316 DotNet SendKeys should only be used on Windows Client in OnOpenPage()

    Caption = 'Generic Setup';
    DataCaptionFields = "Root Element";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Gen. Setup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = Name;
                ShowAsTree = true;
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Enabled = false;
                    Style = Strong;
                    StyleExpr = Container;
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    Enabled = NOT Container;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if "Root Element" <> '' then
            CurrPage.Caption("Root Element");
    end;

    trigger OnOpenPage()
    var
        [RunOnClient]
        SendKeys: DotNet NPRNetSendKeys;
    begin
        //-MAG2.01 [262316]
        //SendKeys.Send('+{F10}E{ENTER}');
        if CurrentClientType = CLIENTTYPE::Windows then
            SendKeys.Send('+{F10}E{ENTER}');
        //+MAG2.01 [262316]
    end;

    procedure SetEditable(IsEditable: Boolean)
    begin
        CurrPage.Editable(IsEditable);
    end;

    procedure SetSourceTable(var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    begin
        //-MAG1.21
        Copy(TempGenericSetupBuffer, true);
        //+MAG1.21
    end;
}


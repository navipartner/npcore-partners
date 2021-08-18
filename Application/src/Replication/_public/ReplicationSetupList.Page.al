page 6014499 "NPR Replication Setup List"
{

    ApplicationArea = NPRRetail;
    Caption = 'Replication API Setup List';
    CardPageId = "NPR Replication Setup Card";
    Editable = false;
    Extensible = true;
    PageType = List;
    SourceTable = "NPR Replication Service Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Name.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Setup is Enabled. If Disabled system will not execute import for the endpoints related to this Setup ';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnRegisterService();
    end;

}

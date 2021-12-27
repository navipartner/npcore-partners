page 6151550 "NPR NpXml Setup"
{
    Caption = 'NpXml Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NpXml Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("NpXml Enabled"; Rec."NpXml Enabled")
                {

                    ToolTip = 'Specifies the value of the NpXml Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Version Prefix"; Rec."Template Version Prefix")
                {

                    ToolTip = 'Specifies the value of the Template Version Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Version No."; Rec."Template Version No.")
                {

                    ToolTip = 'Specifies the value of the Template Version No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}


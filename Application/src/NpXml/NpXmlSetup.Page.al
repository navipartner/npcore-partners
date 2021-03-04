page 6151550 "NPR NpXml Setup"
{
    Caption = 'NpXml Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NpXml Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("NpXml Enabled"; "NpXml Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NpXml Enabled field';
                }
                field("Template Version Prefix"; "Template Version Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Version Prefix field';
                }
                field("Template Version No."; "Template Version No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Version No. field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get then
            Insert;
    end;
}


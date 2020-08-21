page 6151550 "NpXml Setup"
{
    // NC1.17/MH/20150622  CASE 216851 Object Created - NpXml specific fields from NaviConnect Setup
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. Added control "NpXml Template Version Prefix"
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NpXml Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("NpXml Enabled"; "NpXml Enabled")
                {
                    ApplicationArea = All;
                }
                field("Template Version Prefix"; "Template Version Prefix")
                {
                    ApplicationArea = All;
                }
                field("Template Version No."; "Template Version No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if not Get then
            //-NC2.00
            //NpXmlSetupMgt.SetupNpXml();
            Insert;
        //+NC2.00
    end;
}


page 6151562 "NPR NpXml Templ. Arch. List"
{
    // NC1.21/TTH/20151020 CASE 224528 New Object
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Template Archive';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR NpXml Template Arch.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Version No."; "Template Version No.")
                {
                    ApplicationArea = All;
                }
                field("Version Description"; "Version Description")
                {
                    ApplicationArea = All;
                }
                field("Archived by"; "Archived by")
                {
                    ApplicationArea = All;
                }
                field("Archived at"; "Archived at")
                {
                    ApplicationArea = All;
                    Caption = 'Archived At';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Restore Template Version")
            {
                Caption = 'Restore Template Version';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
                begin
                    //-NC1.21
                    if not (Confirm(Text400)) then
                        exit;

                    Clear(NpXmlTemplateMgt);
                    if not NpXmlTemplateMgt.RestoreArchivedNpXmlTemplate(Code, "Template Version No.") then
                        Message(Text200)
                    else
                        Message(StrSubstNo(Text100, "Template Version No."));
                    CurrPage.Close;
                    //+NC1.21
                end;
            }
            action("Export Template Version")
            {
                Caption = 'Export Template Version';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
                begin
                    //-NC1.21
                    Clear(NpXmlTemplateMgt);
                    NpXmlTemplateMgt.ExportArchivedNpXmlTemplate(Rec);
                    //+NC1.21
                end;
            }
        }
    }

    var
        Text100: Label 'Template Version %1 restored';
        Text200: Label 'Restore cancelled';
        Text400: Label 'Replace current version?';
}


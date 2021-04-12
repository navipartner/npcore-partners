page 6151562 "NPR NpXml Templ. Arch. List"
{
    Caption = 'NpXml Template Archive';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpXml Template Arch.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Version No."; Rec."Template Version No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Version No. field';
                }
                field("Version Description"; Rec."Version Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Description field';
                }
                field("Archived by"; Rec."Archived by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived by field';
                }
                field("Archived at"; Rec."Archived at")
                {
                    ApplicationArea = All;
                    Caption = 'Archived At';
                    ToolTip = 'Specifies the value of the Archived At field';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Restore Template Version action';

                trigger OnAction()
                var
                    NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
                begin
                    if not (Confirm(Text400)) then
                        exit;

                    Clear(NpXmlTemplateMgt);
                    if not NpXmlTemplateMgt.RestoreArchivedNpXmlTemplate(Rec.Code, Rec."Template Version No.") then
                        Message(Text200)
                    else
                        Message(StrSubstNo(Text100, Rec."Template Version No."));
                    CurrPage.Close();
                end;
            }
            action("Export Template Version")
            {
                Caption = 'Export Template Version';
                Image = Export;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Export Template Version action';

                trigger OnAction()
                var
                    NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
                begin
                    Clear(NpXmlTemplateMgt);
                    NpXmlTemplateMgt.ExportArchivedNpXmlTemplate(Rec);
                end;
            }
        }
    }

    var
        Text100: Label 'Template Version %1 restored';
        Text200: Label 'Restore cancelled';
        Text400: Label 'Replace current version?';
}


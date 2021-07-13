page 6151562 "NPR NpXml Templ. Arch. List"
{
    Caption = 'NpXml Template Archive';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpXml Template Arch.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Template Version No."; Rec."Template Version No.")
                {

                    ToolTip = 'Specifies the value of the Template Version No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Version Description"; Rec."Version Description")
                {

                    ToolTip = 'Specifies the value of the Version Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Archived by"; Rec."Archived by")
                {

                    ToolTip = 'Specifies the value of the Archived by field';
                    ApplicationArea = NPRRetail;
                }
                field("Archived at"; Rec."Archived at")
                {

                    Caption = 'Archived At';
                    ToolTip = 'Specifies the value of the Archived At field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Restore Template Version action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Export Template Version action';
                ApplicationArea = NPRRetail;

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


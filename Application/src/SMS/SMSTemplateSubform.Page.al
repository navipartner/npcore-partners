page 6059942 "NPR SMS Template Subform"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR SMS Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = 0;
                field("SMS Text"; Rec."SMS Text")
                {

                    ShowCaption = false;
                    ToolTip = 'Use {{Field Number}} to insert a field value in the text.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.SetCurrentKey("Template Code", "Line No.");
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(InsertReportLink)
            {
                Caption = 'Insert Report Link';
                Enabled = ReportLinkEnabled;

                ToolTip = 'Executes the Insert Report Link action';
                Image = Insert;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    AddReportLink();
                end;
            }
        }
    }

    var
        ReportLinkEnabled: Boolean;

    local procedure AddReportLink()
    var
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSManagement: Codeunit "NPR SMS Management";
    begin
        if SMSTemplateHeader.Get(Rec."Template Code") then
            Rec."SMS Text" += SMSManagement.AFReportLink(SMSTemplateHeader."Report ID");
    end;

    procedure SetReportLinkEnabled(Enabled: Boolean)
    begin
        ReportLinkEnabled := Enabled;
        CurrPage.Update(false);
    end;
}


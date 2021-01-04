page 6059942 "NPR SMS Template Subform"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.40/THRO/20180315 CASE 304312 Added option to insert Azure Function Report Link

    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR SMS Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = 0;
                field("SMS Text"; "SMS Text")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Use {{Field Number}} to insert a field value in the text.';

                    trigger OnValidate()
                    begin
                        SetCurrentKey("Template Code", "Line No.");
                        CurrPage.Update;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Report Link action';

                trigger OnAction()
                begin
                    //-NPR5.40 [304312]
                    AddReportLink;
                    //+NPR5.40 [304312]
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
        //-NPR5.40 [304312]
        if SMSTemplateHeader.Get("Template Code") then
            "SMS Text" += SMSManagement.AFReportLink(SMSTemplateHeader."Report ID");
        //+NPR5.40 [304312]
    end;

    procedure SetReportLinkEnabled(Enabled: Boolean)
    begin
        //-NPR5.40 [304312]
        ReportLinkEnabled := Enabled;
        CurrPage.Update(false);
        //+NPR5.40 [304312]
    end;
}


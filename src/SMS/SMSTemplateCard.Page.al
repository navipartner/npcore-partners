page 6059941 "NPR SMS Template Card"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.30/THRO/20170203 CASE 263182 Added Recipient
    // NPR5.38/THRO/20180108 CASE 301396 Added Action Send Batch SMS
    // NPR5.40/THRO/20180302 CASE 304312 Added "Report ID" and Option to add report link via Azure function
    // NPR5.55/LS/20200407  CASE 387142 Changed caption of Action "Send test SMS" from "Send test SMS" to "Send SMS"

    Caption = 'SMS Template Card';
    PromotedActionCategories = 'New,Process,Report,Functions';
    SourceTable = "NPR SMS Template Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Alt. Sender"; "Alt. Sender")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        TableFiltersEnabled := "Table No." <> 0;
                        //-NPR5.40 [304312]
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
                        //+NPR5.40 [304312]
                    end;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Recipient; Recipient)
                {
                    ApplicationArea = All;
                    Lookup = true;
                }
                field("""Table Filters"".HASVALUE"; "Table Filters".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Filters on Table';
                    Editable = false;
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [304312]
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
                        //+NPR5.40 [304312]
                    end;
                }
            }
            part(SMSTemplateSubform; "NPR SMS Template Subform")
            {
                Caption = 'SMS Content';
                ShowFilter = false;
                SubPageLink = "Template Code" = FIELD(Code);
                SubPageView = SORTING("Template Code", "Line No.");
                UpdatePropagation = Both;
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part("Fields"; "NPR SMS Field List")
            {
                Caption = 'Fields';
                SubPageLink = TableNo = FIELD("Table No.");
                SubPageView = SORTING(TableNo, "No.");
                UpdatePropagation = Both;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Send SMS")
                {
                    Caption = 'Send SMS';
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        SMSManagement.SendTestSMS(Rec);
                    end;
                }
                action("Send batch SMS")
                {
                    Caption = 'Send batch SMS';
                    Image = SendToMultiple;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        //-NPR5.38 [301396]
                        SMSManagement.SendBatchSMS(Rec);
                        //+NPR5.38 [301396]
                    end;
                }
            }
            group(Filters)
            {
                Caption = 'Filters';
                action("Table Filters")
                {
                    Caption = 'Table Filters';
                    Enabled = TableFiltersEnabled;
                    Image = UseFilters;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        OpenFilterPage;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TableFiltersEnabled := "Table No." <> 0;
        //-NPR5.40 [304312]
        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
        //+NPR5.40 [304312]
    end;

    var
        TableFiltersEnabled: Boolean;
}


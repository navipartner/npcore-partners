page 6059941 "NPR SMS Template Card"
{
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Alt. Sender"; "Alt. Sender")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alt. Sender field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';

                    trigger OnValidate()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        TableFiltersEnabled := "Table No." <> 0;
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
                    end;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field(Recipient; Recipient)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    ToolTip = 'Specifies the value of the Recipient field';
                }
                field("""Table Filters"".HASVALUE"; "Table Filters".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Filters on Table';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Filters on Table field';
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Report ID field';

                    trigger OnValidate()
                    begin
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
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
                    ToolTip = 'Executes the Send SMS action';

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
                    ToolTip = 'Executes the Send batch SMS action';

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        SMSManagement.SendBatchSMS(Rec);
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
                    ToolTip = 'Executes the Table Filters action';

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
        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
    end;

    var
        TableFiltersEnabled: Boolean;
}


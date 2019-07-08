page 6059941 "SMS Template Card"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.30/THRO/20170203 CASE 263182 Added Recipient
    // NPR5.38/THRO/20180108 CASE 301396 Added Action Send Batch SMS
    // NPR5.40/THRO/20180302 CASE 304312 Added "Report ID" and Option to add report link via Azure function

    Caption = 'SMS Template Card';
    PromotedActionCategories = 'New,Process,Report,Functions';
    SourceTable = "SMS Template Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Alt. Sender";"Alt. Sender")
                {
                }
                field("Table No.";"Table No.")
                {

                    trigger OnValidate()
                    var
                        SMSManagement: Codeunit "SMS Management";
                    begin
                        TableFiltersEnabled := "Table No." <> 0;
                        //-NPR5.40 [304312]
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
                        //+NPR5.40 [304312]
                    end;
                }
                field("Table Caption";"Table Caption")
                {
                    Editable = false;
                }
                field(Recipient;Recipient)
                {
                    Lookup = true;
                }
                field("""Table Filters"".HASVALUE";"Table Filters".HasValue)
                {
                    Caption = 'Filters on Table';
                    Editable = false;
                }
                field("Report ID";"Report ID")
                {
                    Importance = Additional;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [304312]
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and ("Table No." <> 0) and ("Report ID" <> 0));
                        //+NPR5.40 [304312]
                    end;
                }
            }
            part(SMSTemplateSubform;"SMS Template Subform")
            {
                Caption = 'SMS Content';
                ShowFilter = false;
                SubPageLink = "Template Code"=FIELD(Code);
                SubPageView = SORTING("Template Code","Line No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Fields";"SMS Field List")
            {
                Caption = 'Fields';
                SubPageLink = TableNo=FIELD("Table No.");
                SubPageView = SORTING(TableNo,"No.");
                UpdatePropagation = Both;
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
                action("Send test SMS")
                {
                    Caption = 'Send test SMS';
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "SMS Management";
                    begin
                        SMSManagement.SendTestSMS(Rec);
                    end;
                }
                action("Send batch SMS")
                {
                    Caption = 'Send batch SMS';
                    Image = SendToMultiple;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "SMS Management";
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


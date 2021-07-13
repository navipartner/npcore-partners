page 6059941 "NPR SMS Template Card"
{
    UsageCategory = None;
    Caption = 'SMS Template Card';
    PromotedActionCategories = 'New,Process,Report,Functions';
    SourceTable = "NPR SMS Template Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Alt. Sender"; Rec."Alt. Sender")
                {

                    ToolTip = 'Specifies the value of the Alt. Sender field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        TableFiltersEnabled := Rec."Table No." <> 0;
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and (Rec."Table No." <> 0) and (Rec."Report ID" <> 0));
                    end;
                }
                field("Table Caption"; Rec."Table Caption")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Recipient Type"; Rec."Recipient Type")
                {

                    ToolTip = 'Specifies the value of the Recipient Type field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        SetRecipientType()
                    end;
                }
                group(RecipientFld)
                {
                    Visible = not RecipientGroupVisible;
                    ShowCaption = false;
                    field(Recipient; Rec.Recipient)
                    {

                        Lookup = true;
                        ToolTip = 'Specifies the value of the Recipient field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(RecipientGrp)
                {
                    Visible = RecipientGroupVisible;
                    ShowCaption = false;
                    field("Recipient Group"; Rec."Recipient Group")
                    {

                        Lookup = true;
                        ToolTip = 'Specifies the value of the Recipient Group field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Filters on Table"; Rec."Table Filters".HasValue)
                {

                    Caption = 'Filters on Table';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Filters on Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and (Rec."Table No." <> 0) and (Rec."Report ID" <> 0));
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
                ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    ToolTip = 'Executes the Send SMS action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        SMSManagement: Codeunit "NPR SMS Management";
                    begin
                        SMSManagement.SendTestSMS(Rec);
                    end;
                }
                action("Send batch SMS")
                {
                    Caption = 'Send Batch SMS';
                    Image = SendToMultiple;

                    ToolTip = 'Executes the Send Batch SMS action';
                    ApplicationArea = NPRRetail;

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
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    ToolTip = 'Executes the Table Filters action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.OpenFilterPage();
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetRecipientType()
    end;

    trigger OnAfterGetCurrRecord()
    begin
        TableFiltersEnabled := Rec."Table No." <> 0;
        CurrPage.SMSTemplateSubform.PAGE.SetReportLinkEnabled(CurrPage.Editable and (Rec."Table No." <> 0) and (Rec."Report ID" <> 0));
        SetRecipientType();
    end;

    local procedure SetRecipientType()
    begin
        RecipientGroupVisible := Rec."Recipient Type" = Rec."Recipient Type"::Group;
    end;

    var
        TableFiltersEnabled: Boolean;
        RecipientGroupVisible: Boolean;
}


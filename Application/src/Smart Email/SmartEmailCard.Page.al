page 6059822 "NPR Smart Email Card"
{
    Extensible = False;
    Caption = 'Smart Email Card';
    PageType = Card;
    SourceTable = "NPR Smart Email";
    UsageCategory = None;
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
                field(Provider; Rec.Provider)
                {

                    ToolTip = 'Specifies the value of the Provider field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ShowMergeLanguage := Rec.Provider = Rec.Provider::Mailchimp;
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {

                    ToolTip = 'Specifies the value of the Merge Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {

                    ToolTip = 'Specifies the value of the Table Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Smart Email ID"; Rec."Smart Email ID")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Smart Email ID field';
                    ApplicationArea = NPRRetail;
                }
                field("NpXml Template Code"; Rec."NpXml Template Code")
                {

                    ToolTip = 'Specifies the value of the NpXml Template Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ShowVariablesSubPage := Rec."NpXml Template Code" = '';
                    end;
                }
                group(Control6014402)
                {
                    ShowCaption = false;
                    Visible = ShowMergeLanguage;
                    field("Merge Language (Mailchimp)"; Rec."Merge Language (Mailchimp)")
                    {

                        ToolTip = 'Specifies the value of the Merge Language (Mailchimp) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(TemplateDetails)
            {
                Caption = 'Template Details';
                Editable = false;
                field("Smart Email Name"; Rec."Smart Email Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Smart Email Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Subject; Rec.Subject)
                {

                    ToolTip = 'Specifies the value of the Subject field';
                    ApplicationArea = NPRRetail;
                }
                field(From; Rec.From)
                {

                    ToolTip = 'Specifies the value of the From field';
                    ApplicationArea = NPRRetail;
                }
                field("Reply To"; Rec."Reply To")
                {

                    ToolTip = 'Specifies the value of the Reply To field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6014403; "NPR Smart Email Variables")
            {

                SubPageLink = "Transactional Email Code" = FIELD(Code);
                Visible = ShowVariablesSubPage;
                ApplicationArea = NPRRetail;
            }
            group("Preview")
            {
                Caption = 'Preview';
                field("Preview Url"; Rec."Preview Url")
                {

                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the Preview Url field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
                    begin
                        TransactionalEmailMgt.PreviewSmartEmail(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowVariablesSubPage := Rec."NpXml Template Code" = '';
        ShowMergeLanguage := Rec.Provider = Rec.Provider::Mailchimp;
    end;

    var
        ShowMergeLanguage: Boolean;
        ShowVariablesSubPage: Boolean;
}


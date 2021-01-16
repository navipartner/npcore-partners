page 6059822 "NPR Smart Email Card"
{
    UsageCategory = None;
    Caption = 'Smart Email Card';
    PageType = Card;
    SourceTable = "NPR Smart Email";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';

                    trigger OnValidate()
                    begin
                        ShowMergeLanguage := Rec.Provider = Rec.Provider::Mailchimp;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merge Table ID field';
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("Smart Email ID"; Rec."Smart Email ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Smart Email ID field';
                }
                field("NpXml Template Code"; Rec."NpXml Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NpXml Template Code field';

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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Merge Language (Mailchimp) field';
                    }
                }
            }
            group(TemplateDetails)
            {
                Caption = 'Template Details';
                Editable = false;
                field("Smart Email Name"; Rec."Smart Email Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Smart Email Name field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field(From; Rec.From)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From field';
                }
                field("Reply To"; Rec."Reply To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reply To field';
                }
            }
            part(Control6014403; "NPR Smart Email Variables")
            {
                SubPageLink = "Transactional Email Code" = FIELD(Code);
                Visible = ShowVariablesSubPage;
                ApplicationArea = All;
            }
            group("Preview")
            {
                Caption = 'Preview';
                field("Preview Url"; Rec."Preview Url")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the Preview Url field';

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

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ShowVariablesSubPage := Rec."NpXml Template Code" = '';
        ShowMergeLanguage := Rec.Provider = Rec.Provider::Mailchimp;
    end;

    var
        ShowVariablesSubPage: Boolean;
        ShowMergeLanguage: Boolean;
}


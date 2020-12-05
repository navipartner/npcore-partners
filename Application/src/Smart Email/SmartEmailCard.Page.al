page 6059822 "NPR Smart Email Card"
{
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
                }
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ShowMergeLanguage := Rec.Provider = Rec.Provider::Mailchimp;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Merge Table ID"; Rec."Merge Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                }
                field("Smart Email ID"; Rec."Smart Email ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("NpXml Template Code"; Rec."NpXml Template Code")
                {
                    ApplicationArea = All;

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
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = All;
                }
                field(From; Rec.From)
                {
                    ApplicationArea = All;
                }
                field("Reply To"; Rec."Reply To")
                {
                    ApplicationArea = All;
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


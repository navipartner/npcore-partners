page 6059822 "NPR Smart Email Card"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.44/THRO/20180723 CASE 310042 Added "NpXml Template Code"
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider

    Caption = 'Smart Email Card';
    PageType = Card;
    SourceTable = "NPR Smart Email";

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
                field(Provider; Provider)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.55 [343266]
                        ShowMergeLanguage := Provider = Provider::Mailchimp;
                        //+NPR5.55 [343266]
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Merge Table ID"; "Merge Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                }
                field("Smart Email ID"; "Smart Email ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("NpXml Template Code"; "NpXml Template Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.44 [310042]
                        ShowVariablesSubPage := "NpXml Template Code" = '';
                        //+NPR5.44 [310042]
                    end;
                }
                group(Control6014402)
                {
                    ShowCaption = false;
                    Visible = ShowMergeLanguage;
                    field("Merge Language (Mailchimp)"; "Merge Language (Mailchimp)")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(TemplateDetails)
            {
                Caption = 'Template Details';
                Editable = false;
                field("Smart Email Name"; "Smart Email Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                }
                field(From; From)
                {
                    ApplicationArea = All;
                }
                field("Reply To"; "Reply To")
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
                field("Preview Url"; "Preview Url")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ExtendedDatatype = URL;

                    trigger OnDrillDown()
                    var
                        TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
                    begin
                        //-NPR5.55 [343266]
                        TransactionalEmailMgt.PreviewSmartEmail(Rec);
                        //+NPR5.55 [343266]
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
        //-NPR5.44 [310042]
        ShowVariablesSubPage := "NpXml Template Code" = '';
        //+NPR5.44 [310042]
        //-NPR5.55 [343266]
        ShowMergeLanguage := Provider = Provider::Mailchimp;
        //+NPR5.55 [343266]
    end;

    var
        ShowVariablesSubPage: Boolean;
        ShowMergeLanguage: Boolean;
}


page 6059822 "Smart Email Card"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.44/THRO/20180723 CASE 310042 Added "NpXml Template Code"
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider

    Caption = 'Smart Email Card';
    PageType = Card;
    SourceTable = "Smart Email";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Provider;Provider)
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.55 [343266]
                        ShowMergeLanguage := Provider = Provider::Mailchimp;
                        //+NPR5.55 [343266]
                    end;
                }
                field(Description;Description)
                {
                }
                field("Merge Table ID";"Merge Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Smart Email ID";"Smart Email ID")
                {
                    ShowMandatory = true;
                }
                field("NpXml Template Code";"NpXml Template Code")
                {

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
                    field("Merge Language (Mailchimp)";"Merge Language (Mailchimp)")
                    {
                    }
                }
            }
            group(TemplateDetails)
            {
                Caption = 'Template Details';
                Editable = false;
                field("Smart Email Name";"Smart Email Name")
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field(Subject;Subject)
                {
                }
                field(From;From)
                {
                }
                field("Reply To";"Reply To")
                {
                }
            }
            part(Control6014403;"Smart Email Variables")
            {
                SubPageLink = "Transactional Email Code"=FIELD(Code);
                Visible = ShowVariablesSubPage;
            }
            group(Preview)
            {
                Caption = 'Preview';
                field("Preview Url";"Preview Url")
                {
                    Editable = false;
                    ExtendedDatatype = URL;

                    trigger OnDrillDown()
                    var
                        TransactionalEmailMgt: Codeunit "Transactional Email Mgt.";
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


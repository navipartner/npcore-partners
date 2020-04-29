page 6059822 "Smart Email Card"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.44/THRO/20180723 CASE 310042 Added "NpXml Template Code"

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
            }
            group("Campaign Monitor")
            {
                Caption = 'Campaign Monitor';
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
            part(Control6150629;"Smart Email Variables")
            {
                SubPageLink = "Transactional Email Code"=FIELD(Code);
                Visible = ShowVariablesSubPage;
            }
            group(Control6150617)
            {
                ShowCaption = false;
                field("Preview Url";"Preview Url")
                {
                    Editable = false;
                    ExtendedDatatype = URL;
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
    end;

    var
        ShowVariablesSubPage: Boolean;
}


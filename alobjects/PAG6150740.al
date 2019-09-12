page 6150740 "POS Admin. Template Card"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Administrative Template Card';
    DataCaptionExpression = GetName();
    DataCaptionFields = Id,Name;
    PageType = Card;
    SourceTable = "POS Administrative Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id;Id)
                {
                    Importance = Additional;
                }
                field(Name;Name)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Version;Version)
                {
                }
                field(Status;Status)
                {
                }
                field("Persist on Client";"Persist on Client")
                {
                }
            }
            group(MainMenu)
            {
                Caption = 'Main Menu';
                field("Role Center";"Role Center")
                {

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Role Center Password";"Role Center Password")
                {
                    Editable = RoleCenterPasswordEditable;
                }
                field(Configuration;Configuration)
                {

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Configuration Password";"Configuration Password")
                {
                    Editable = ConfigurationPasswordEditable;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Scopes)
            {
                Caption = 'Scopes';
                Image = UserInterface;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Admin. Template Scopes";
                RunPageLink = "POS Admin. Template Id"=FIELD(Id);
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlStatuses();
    end;

    var
        Text001: Label 'Unnamed template (%1)';
        RoleCenterPasswordEditable: Boolean;
        ConfigurationPasswordEditable: Boolean;

    local procedure GetName(): Text
    begin
        if Name <> '' then
          exit(Name)
        else
          exit(StrSubstNo(Text001,Id));
    end;

    local procedure SetControlStatuses()
    begin
        RoleCenterPasswordEditable := "Role Center" = "Role Center"::Password;
        ConfigurationPasswordEditable := Configuration = Configuration::Password;
    end;
}


page 6150740 "NPR POS Admin. Template Card"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Administrative Template Card';
    DataCaptionExpression = GetName();
    DataCaptionFields = Id, Name;
    PageType = Card;
    SourceTable = "NPR POS Admin. Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Persist on Client"; "Persist on Client")
                {
                    ApplicationArea = All;
                }
            }
            group(MainMenu)
            {
                Caption = 'Main Menu';
                field("Role Center"; "Role Center")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Role Center Password"; "Role Center Password")
                {
                    ApplicationArea = All;
                    Editable = RoleCenterPasswordEditable;
                }
                field(Configuration; Configuration)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Configuration Password"; "Configuration Password")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR POS Admin. Template Scopes";
                RunPageLink = "POS Admin. Template Id" = FIELD(Id);
                ApplicationArea=All;
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
            exit(StrSubstNo(Text001, Id));
    end;

    local procedure SetControlStatuses()
    begin
        RoleCenterPasswordEditable := "Role Center" = "Role Center"::Password;
        ConfigurationPasswordEditable := Configuration = Configuration::Password;
    end;
}


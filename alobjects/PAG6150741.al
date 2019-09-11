page 6150741 "POS Admin. Template List"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Admin. Template List';
    CardPageID = "POS Admin. Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Administrative Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                    Visible = false;
                }
                field(Name;Name)
                {
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
}


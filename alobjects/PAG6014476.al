page 6014476 "Retail Document List"
{
    // NPR4.000.001, NPK, 12-02-09, MH, Udvidet Kort-knappen under funktion.
    // NPR4.14/JDH/20150831 CASE 221535 Removed obsolete link to Retail Document Card
    // NPR5.35/KENU/20170808 CASE 285990 Set fields to Not Visible and as Additional by default
    // NPR5.35/KENU/20170808 CASE 285991 Hide "Rental Sub Form"
    // NPR5.39/TJ  /20180212 CASE 302634 Renamed Name property of actions to english
    //                                   Renamed OptionString property of variable TypeFilter to english
    //                                   Fixed a bug with case 225415 which renumbered Primary Key Length field used in SourceTableView property

    AutoSplitKey = true;
    Caption = 'Retail Documents';
    CardPageID = "Retail Document Header";
    Editable = true;
    PageType = List;
    SourceTable = "Retail Document Header";
    SourceTableView = SORTING("Primary Key Length");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(Control6150658)
            {
                ShowCaption = false;
                field(TypeFilter;TypeFilter)
                {
                    Caption = 'Document Type';

                    trigger OnValidate()
                    begin
                        SetTypeFilter;
                    end;
                }
            }
            repeater(Group)
            {
                field("Customer No.";"Customer No.")
                {
                    Editable = false;
                }
                field("No.";"No.")
                {
                    Editable = false;
                }
                field(Name;Name)
                {
                    Editable = false;
                }
                field("First Name";"First Name")
                {
                    Editable = false;
                }
                field("Ship-to Name";"Ship-to Name")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Document Date";"Document Date")
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field(Cashed;Cashed)
                {
                    Editable = false;
                }
                field("Vendor Index";"Vendor Index")
                {
                    Editable = false;
                }
                field(Address;Address)
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Address 2";"Address 2")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(City;City)
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(ID;ID)
                {
                    Editable = false;
                }
                field(Date;Date)
                {
                    Editable = false;
                }
                field("Salesperson Code";"Salesperson Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Post Code";"Post Code")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(Deposit;Deposit)
                {
                    Editable = false;
                }
                field(Amount;Amount)
                {
                    Editable = false;
                }
                field("Time of Day";"Time of Day")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Rent Salesperson";"Rent Salesperson")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Rent Register";"Rent Register")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Rent Sales Ticket";"Rent Sales Ticket")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Date";"Return Date")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Time";"Return Time")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Salesperson";"Return Salesperson")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Register";"Return Register")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Sales Ticket";"Return Sales Ticket")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Department";"Return Department")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(Phone;Phone)
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(Mobile;Mobile)
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Date 2";"Return Date 2")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Return Time 2";"Return Time 2")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Rent Date";"Rent Date")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("Rent Time";"Rent Time")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field("No. Series";"No. Series")
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
                field(Comment;Comment)
                {
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                }
            }
            grid(Control6150652)
            {
                ShowCaption = false;
                part(Control6150651;"Retail Document Lines")
                {
                    SubPageLink = "Document Type"=FIELD("Document Type"),
                                  "Document No."=FIELD("No.");
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&ChangeOutstandingRedeemed")
            {
                Caption = 'Change Outstanding / Redeemed';
                Image = ChangePaymentTolerance;

                trigger OnAction()
                begin

                    if GetFilter( Cashed ) = Text10600000 then begin
                      SetRange( Cashed, true );
                    end else begin
                      SetRange( Cashed, false );
                    end;
                end;
            }
            action("&ViewAll")
            {
                Caption = 'View All';
                Image = View;

                trigger OnAction()
                begin

                    SetRange( Cashed );
                end;
            }
        }
    }

    trigger OnInit()
    begin

        bVisible := false;
    end;

    trigger OnOpenPage()
    begin

        if Find('-') then;

        if (GetFilter("Document Type") <> '') then
          if  (GetRangeMin("Document Type") =  GetRangeMax("Document Type")) then
            TypeFilter := GetRangeMin("Document Type");


        i := "Document Type";

        CurrPage.Caption(SelectStr(i+1,Text10600001));

        case "Document Type" of
          "Document Type"::"Selection Contract" :       ;
          "Document Type"::"Retail Order" :;
          "Document Type"::Wish :;
          "Document Type"::Customization :;
        end;
    end;

    var
        Linier: Record "Retail Document Lines";
        UdlejningslinieForm: Page "Retail Document Lines";
        bVisible: Boolean;
        i: Integer;
        Text10600000: Label 'No';
        Text10600001: Label ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
        TypeFilter: Option " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;

    procedure SetVisLinier()
    begin
        bVisible := true;
    end;

    procedure SetTypeFilter()
    begin
        SetRange("Document Type",TypeFilter);
        CurrPage.Update(false);
        CurrPage.Caption(Format(TypeFilter))
    end;
}


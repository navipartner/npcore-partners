page 6014476 "NPR Retail Document List"
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
    CardPageID = "NPR Retail Document Header";
    Editable = true;
    PageType = List;
    SourceTable = "NPR Retail Document Header";
    SourceTableView = SORTING("Primary Key Length");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(Control6150658)
            {
                ShowCaption = false;
                field(TypeFilter; TypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the value of the Document Type field';

                    trigger OnValidate()
                    begin
                        SetTypeFilter;
                    end;
                }
            }
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Date Created field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Cashed; Cashed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cashed field';
                }
                field("Vendor Index"; "Vendor Index")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Index field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Address 2 field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the City field';
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(Deposit; Deposit)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Deposit field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total amount field';
                }
                field("Time of Day"; "Time of Day")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field("Rent Salesperson"; "Rent Salesperson")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rent Salesperson field';
                }
                field("Rent Register"; "Rent Register")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rent Cash Register No. field';
                }
                field("Rent Sales Ticket"; "Rent Sales Ticket")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rent Sales Ticket field';
                }
                field("Return Date"; "Return Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Date field';
                }
                field("Return Time"; "Return Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Time field';
                }
                field("Return Salesperson"; "Return Salesperson")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Salesperson field';
                }
                field("Return Register"; "Return Register")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Cash Register No. field';
                }
                field("Return Sales Ticket"; "Return Sales Ticket")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Sales Ticket field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Return Department"; "Return Department")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Department field';
                }
                field(Phone; Phone)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Phone field';
                }
                field(Mobile; Mobile)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cell No. field';
                }
                field("Return Date 2"; "Return Date 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Date 2 field';
                }
                field("Return Time 2"; "Return Time 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Time 2 field';
                }
                field("Rent Date"; "Rent Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rent Date field';
                }
                field("Rent Time"; "Rent Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Rent Time field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Comment field';
                }
            }
            grid(Control6150652)
            {
                ShowCaption = false;
                part(Control6150651; "NPR Retail Document Lines")
                {
                    SubPageLink = "Document Type" = FIELD("Document Type"),
                                  "Document No." = FIELD("No.");
                    Visible = false;
                    ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Change Outstanding / Redeemed action';

                trigger OnAction()
                begin

                    if GetFilter(Cashed) = Text10600000 then begin
                        SetRange(Cashed, true);
                    end else begin
                        SetRange(Cashed, false);
                    end;
                end;
            }
            action("&ViewAll")
            {
                Caption = 'View All';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'Executes the View All action';

                trigger OnAction()
                begin

                    SetRange(Cashed);
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
            if (GetRangeMin("Document Type") = GetRangeMax("Document Type")) then
                TypeFilter := GetRangeMin("Document Type");


        i := "Document Type";

        CurrPage.Caption(SelectStr(i + 1, Text10600001));

        case "Document Type" of
            "Document Type"::"Selection Contract":
                ;
            "Document Type"::"Retail Order":
                ;
            "Document Type"::Wish:
                ;
            "Document Type"::Customization:
                ;
        end;
    end;

    var
        Linier: Record "NPR Retail Document Lines";
        UdlejningslinieForm: Page "NPR Retail Document Lines";
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
        SetRange("Document Type", TypeFilter);
        CurrPage.Update(false);
        CurrPage.Caption(Format(TypeFilter))
    end;
}


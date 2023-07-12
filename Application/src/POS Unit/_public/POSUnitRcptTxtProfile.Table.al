table 6150654 "NPR POS Unit Rcpt.Txt Profile"
{
    Caption = 'POS Unit Receipt Text Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Unit Rcpt.Txt Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Ticket Line Text off"; Option)
        {
            Caption = 'Sales Ticket Line Text off';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Pos Unit,Comment';
            OptionMembers = "Pos Unit",Comment;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(11; "Sales Ticket Line Text1"; Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(12; "Sales Ticket Line Text2"; Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(13; "Sales Ticket Line Text3"; Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(14; "Sales Ticket Line Text4"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(15; "Sales Ticket Line Text5"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(16; "Sales Ticket Line Text6"; Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(17; "Sales Ticket Line Text7"; Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(18; "Sales Ticket Line Text8"; Code[50])
        {
            Caption = 'Sales Ticket Line Text8';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(19; "Sales Ticket Line Text9"; Code[50])
        {
            Caption = 'Sales Ticket Line Text9';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(20; "Sales Ticket Rcpt. Text"; Text[2048])
        {
            Caption = 'Sales Ticket Receipt Text';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use Text Receipt preview lines to set directly receipt text';
        }
        field(30; "Break Line"; Integer)
        {
            Caption = 'Break Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use Text Receipt preview lines to set directly receipt text';
        }       
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }


    trigger OnDelete()
    var
        TicketReceiptText: Record "NPR POS Ticket Rcpt. Text";
    begin
        TicketReceiptText.DeleteAllForCurrProfile(Rec.Code);
    end;
}


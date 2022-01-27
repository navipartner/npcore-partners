table 6014500 "NPR Used Goods Registration"
{
    Access = Internal;
    Caption = 'Used Goods Registration';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }
        field(3; Subject; Text[30])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[30])
        {
            Caption = 'Subject Description';
            DataClassification = CustomerContent;
        }
        field(5; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(6; Paid; Option)
        {
            Caption = 'Paid';
            OptionCaption = ' ,Check,Cash,Exchange';
            OptionMembers = " ",Check,Kontant,Bytte;
            DataClassification = CustomerContent;
        }
        field(7; "Check Number"; Code[20])
        {
            Caption = 'Check Number';
            DataClassification = CustomerContent;
        }
        field(20; "Purchased By Customer No."; Code[20])
        {
            Caption = 'Purchase Customer No.';
            DataClassification = CustomerContent;
        }
        field(21; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(22; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(23; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(24; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
        }
        field(25; Identification; Option)
        {
            Caption = 'ID Card';
            OptionCaption = ' ,Driver''s Licence,Passport,Credit Card,Other';
            OptionMembers = " ","Driver's Licence",Passport,"Credit Card",Other;
            DataClassification = CustomerContent;
        }
        field(26; "CPR No."; Code[11])
        {
            Caption = 'Social Security No.';
            DataClassification = CustomerContent;
        }
        field(27; "Identification Number"; Code[20])
        {
            Caption = 'Legitimation No.';
            DataClassification = CustomerContent;
        }
        field(28; "Fax til Kostercentralen"; Boolean)
        {
            Caption = 'Fax to Kostercentralen';
            DataClassification = CustomerContent;
        }
        field(29; "Subject Sold Date"; Date)
        {
            Caption = 'Subject Sold Date';
            DataClassification = CustomerContent;
        }
        field(30; "Sales Ticket No./Invoice No."; Code[10])
        {
            Caption = 'On Sales Ticket No./Invoice';
            DataClassification = CustomerContent;
        }
        field(31; "Item No. Created"; Code[20])
        {
            Caption = 'Generated Item No.';
            DataClassification = CustomerContent;
        }
        field(32; "Kostercentralen Registered"; Date)
        {
            Caption = 'Kostercentralen Registered Date';
            DataClassification = CustomerContent;
        }
        field(33; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(34; Puljemomsordning; Boolean)
        {
            Caption = 'Pool  VAT System';
            DataClassification = CustomerContent;
        }
        field(35; "Relation til faktura"; Code[10])
        {
            Caption = 'Relation to Invoice';
            DataClassification = CustomerContent;
        }
        field(36; "Salgspris inkl. Moms"; Decimal)
        {
            Caption = 'Unit Price Including VAT';
            DataClassification = CustomerContent;
        }
        field(37; Nummerserie; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(38; By; Code[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(39; Serienummer; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(42; Link; Code[10])
        {
            Caption = 'Link';
            DataClassification = CustomerContent;
        }
        field(43; "Brugtvare lagermetode"; Option)
        {
            Caption = 'Used Goods Inventory Method';
            OptionCaption = 'FIFO,LIFO,Serial No.,Avarage,Standard';
            OptionMembers = FIFO,LIFO,Serienummer,Gennemsnit,Standard;
            DataClassification = CustomerContent;
        }
        field(44; "Item Group No."; Code[10])
        {
            Caption = 'Belongs in Item Group No.';
            DataClassification = CustomerContent;
        }
        field(45; Stand; Option)
        {
            Caption = 'Condition';
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,B+';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,"B+";
            DataClassification = CustomerContent;
        }
        field(46; "Search Name"; Text[30])
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(47; "Rettet den"; Date)
        {
            Caption = 'Edited Date';
            DataClassification = CustomerContent;
        }
        field(50; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(55; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'MainPost,SinglePost,SubPost';
            OptionMembers = MainPost,SinglePost,SubPost;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            SumIndexFields = "Unit Cost";
        }
    }

    fieldgroups
    {
    }
}


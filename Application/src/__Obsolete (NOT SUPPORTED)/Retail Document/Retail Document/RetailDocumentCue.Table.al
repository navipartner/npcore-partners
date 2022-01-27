table 6059985 "NPR Retail Document Cue"
{
    Access = Internal;
    Caption = 'Retail Document Cue';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Table not used anymore';
    ObsoleteTag = 'Deprecating 16/2/2021';


    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Selection Contracts Open"; Integer)
        {
            Caption = 'Selection Contracts Open';
            FieldClass = FlowField;
        }
        field(3; "Retail Orders Open"; Integer)
        {
            Caption = 'Retail Orders Open';
            FieldClass = FlowField;
        }
        field(4; "Wishlist Open"; Integer)
        {
            Caption = 'Wishlist Open';
            FieldClass = FlowField;
        }
        field(5; "Customizations Open"; Integer)
        {
            Caption = 'Customizations Open';
            FieldClass = FlowField;
        }
        field(6; "Rental Contracts Open"; Integer)
        {
            Caption = 'Rental Contracts Open';
            FieldClass = FlowField;
        }
        field(7; "Purchase Contracts Open"; Integer)
        {
            Caption = 'Purchase Contracts Open';
            FieldClass = FlowField;
        }
        field(8; "Quotes Open"; Integer)
        {
            Caption = 'Quotes Open';
            FieldClass = FlowField;
        }
        field(12; "Selection Contracts Cashed"; Integer)
        {
            Caption = 'Selection Contracts Cashed';
            FieldClass = FlowField;
        }
        field(13; "Retail Orders Cashed"; Integer)
        {
            Caption = 'Retail Orders Cashed';
            FieldClass = FlowField;
        }
        field(14; "Wishlist Cashed"; Integer)
        {
            Caption = 'Wishlist Cashed';
            FieldClass = FlowField;
        }
        field(15; "Customizations Cashed"; Integer)
        {
            Caption = 'Customizations Cashed';
            FieldClass = FlowField;
        }
        field(16; "Rental Contracts Cashed"; Integer)
        {
            Caption = 'Rental Contracts Cashed';
            FieldClass = FlowField;
        }
        field(17; "Purchase Contracts Cashed"; Integer)
        {
            Caption = 'Purchase Contracts Cashed';
            FieldClass = FlowField;
        }
        field(18; "Quotes Cashed"; Integer)
        {
            Caption = 'Quotes Cashed';
            FieldClass = FlowField;
        }
        field(20; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(21; "Date Filter 2"; Date)
        {
            Caption = 'Date Filter 2';
            FieldClass = FlowFilter;
        }
        field(30; "Number of Open Orders"; Integer)
        {
            Caption = 'Open Orders';
            FieldClass = FlowField;
        }
        field(31; "Number of Posted Orders"; Integer)
        {
            Caption = 'Posted Orders';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}


table 6150669 "NPR NPRE Restaurant Setup"
{
    Caption = 'Restaurant Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Waiter Pad No. Serie"; Code[20])
        {
            Caption = 'Waiter Pad No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(11; "Kitchen Order Template"; Code[20])
        {
            Caption = 'Kitchen Order Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
            ValidateTableRelation = true;
        }
        field(12; "Pre Receipt Template"; Code[20])
        {
            Caption = 'Pre Receipt Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(13; "Auto Send Kitchen Order"; Option)
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = No,Yes,Ask;
        }
        field(14; "Resend All On New Lines"; Option)
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = No,Yes,Ask;
        }
        field(15; "Serving Step Discovery Method"; Option)
        {
            Caption = 'Serving Step Discovery Method';
            DataClassification = CustomerContent;
            InitValue = "Item Routing Profiles";
            OptionCaption = 'Legacy (using print tags),Item Routing Profiles';
            OptionMembers = "Legacy (using print tags)","Item Routing Profiles";
        }
        field(20; "Kitchen Printing Active"; Boolean)
        {
            Caption = 'Kitchen Printing Active';
            DataClassification = CustomerContent;
        }
        field(30; "KDS Active"; Boolean)
        {
            Caption = 'KDS Active';
            DataClassification = CustomerContent;
        }
        field(40; "Station Req. Handl. On Serving"; Option)
        {
            Caption = 'Station Req. Handl. On Serving';
            DataClassification = CustomerContent;
            OptionCaption = 'Do Nothing,Finish Started,Finish All,Finish Started/Cancel Not Started,Cancel All Unfinished';
            OptionMembers = "Do Nothing","Finish Started","Finish All","Finish Started/Cancel Not Started","Cancel All Unfinished";
        }
        field(60; "Order ID Assign. Method"; Option)
        {
            Caption = 'Order ID Assign. Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Same for Source Document,New Each Time';
            OptionMembers = "Same for Source Document","New Each Time";
        }
        field(70; "Seat.Status: Ready"; Code[10])
        {
            Caption = 'Seat.Status: Ready';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(71; "Seat.Status: Occupied"; Code[10])
        {
            Caption = 'Seat.Status: Occupied';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(72; "Seat.Status: Reserved"; Code[10])
        {
            Caption = 'Seat.Status: Reserved';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(73; "Seat.Status: Cleaning Required"; Code[10])
        {
            Caption = 'Seat.Status: Cleaning Required';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(80; "Component No. Series"; Code[20])
        {
            Caption = 'Component No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(90; "Default Service Flow Profile"; Code[20])
        {
            Caption = 'Default Service Flow Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Serv.Flow Profile";
        }
        field(100; "New Waiter Pad Action"; Code[20])
        {
            Caption = 'New Waiter Pad Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("New Waiter Pad Action"));
                ParamMgt.CopyFromActionToField("New Waiter Pad Action", RecordId, FieldNo("New Waiter Pad Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("New Waiter Pad Action") then
                    Validate("New Waiter Pad Action");
            end;
        }
        field(105; "Select Waiter Pad Action"; Code[20])
        {
            Caption = 'Select Waiter Pad Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Select Waiter Pad Action"));
                ParamMgt.CopyFromActionToField("Select Waiter Pad Action", RecordId, FieldNo("Select Waiter Pad Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Select Waiter Pad Action") then
                    Validate("Select Waiter Pad Action");
            end;
        }
        field(110; "Select Table Action"; Code[20])
        {
            Caption = 'Select Table Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Select Table Action"));
                ParamMgt.CopyFromActionToField("Select Table Action", RecordId, FieldNo("Select Table Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Select Table Action") then
                    Validate("Select Table Action");
            end;
        }
        field(115; "Select Restaurant Action"; Code[20])
        {
            Caption = 'Select Restaurant Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Select Restaurant Action"));
                ParamMgt.CopyFromActionToField("Select Restaurant Action", RecordId, FieldNo("Select Restaurant Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Select Restaurant Action") then
                    Validate("Select Restaurant Action");
            end;
        }
        field(120; "Save Layout Action"; Code[20])
        {
            Caption = 'Save Layout Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Save Layout Action"));
                ParamMgt.CopyFromActionToField("Save Layout Action", RecordId, FieldNo("Save Layout Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Save Layout Action") then
                    Validate("Save Layout Action");
            end;
        }
        field(130; "Set Waiter Pad Status Action"; Code[20])
        {
            Caption = 'Set Waiter Pad Status Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Set Waiter Pad Status Action"));
                ParamMgt.CopyFromActionToField("Set Waiter Pad Status Action", RecordId, FieldNo("Set Waiter Pad Status Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Set Waiter Pad Status Action") then
                    Validate("Set Waiter Pad Status Action");
            end;
        }
        field(135; "Set Table Status Action"; Code[20])
        {
            Caption = 'Set Table Status Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Set Table Status Action"));
                ParamMgt.CopyFromActionToField("Set Table Status Action", RecordId, FieldNo("Set Table Status Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Set Table Status Action") then
                    Validate("Set Table Status Action");
            end;
        }
        field(140; "Set Number of Guests Action"; Code[20])
        {
            Caption = 'Set Number of Guests Action';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Set Number of Guests Action"));
                ParamMgt.CopyFromActionToField("Set Number of Guests Action", RecordId, FieldNo("Set Number of Guests Action"));
            end;

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Set Number of Guests Action") then
                    Validate("Set Number of Guests Action");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        ActionMgt: Codeunit "NPR POS Action Management";
}

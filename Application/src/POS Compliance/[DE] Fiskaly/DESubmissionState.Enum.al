enum 6059845 "NPR DE Submission State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; CREATED)
    {
        Caption = 'Created';
    }
    value(2; VALIDATION_TRIGGERED)
    {
        Caption = 'Validation Triggered';
    }
    value(3; INTERNAL_VALIDATION_FAILED)
    {
        Caption = 'Internal Validation Failed';
    }
    value(4; EXTERNAL_VALIDATION_FAILED)
    {
        Caption = 'External Validation Failed';
    }
    value(5; VALIDATION_SUCCEEDED)
    {
        Caption = 'Validation Succeeded';
    }
    value(6; XML_GENERATION_SUCCEEDED)
    {
        Caption = 'XML Generation Succeeded';
    }
    value(7; XML_GENERATION_FAILED)
    {
        Caption = 'XML Generation Failed';
    }
    value(8; READY_FOR_TRANSMISSION)
    {
        Caption = 'Ready for Transmission';
    }
    value(9; TRANSMISSION_PENDING)
    {
        Caption = 'Transmission Pending';
    }
    value(10; TRANSMISSION_IN_PROGRESS)
    {
        Caption = 'Transmission in Progress';
    }
    value(11; TRANSMISSION_FAILED)
    {
        Caption = 'Transmission Failed';
    }
    value(12; TRANSMISSION_SUCCEEDED)
    {
        Caption = 'Transmission Succeeded';
    }
    value(13; TRANSMISSION_CANCELLED)
    {
        Caption = 'Transmission Cancelled';
    }
    value(14; ERROR)
    {
        Caption = 'Error';
    }
}

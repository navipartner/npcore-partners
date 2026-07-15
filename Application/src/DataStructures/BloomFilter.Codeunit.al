codeunit 6151273 "NPR Bloom Filter"
{
    Access = Internal;

    // https://en.wikipedia.org/wiki/Bloom_filter

    // A bloom filter is useful in scenarios where it can let you avoid naively performing a heavy operation,
    // such as some expensive calculation or SQL queries against the database.
    // The reason it is useful versus a temp record where you keep all values in memory is that its super small in comparison.
    // For example, 20 million elements packed into a bloom filter build for 0,1% error rate will only take up about 35MB of memory
    // where a temp table might take up 50GB meaning it would not be acceptable in prod.

    // It is also much faster to do a filter lookup versus even a perfectly indexed Record.IsEmpty() or Record.Get();
    // Especially in BC SaaS where the latency between NST and DB is higher than OnPrem/Containers.
    // There is one downside:
    // It takes a while to build up, so do it ideally at the start of something, e.g. when POS launches with
    // filter cached in a SingleInstance codeunit.

    // BE AWARE: When you call MayContain() you always need to double check the true return value by performing
    // the expensive operation afterwards to confirm. This is how bloom filters work. Only a false is trustworthy.

    var
        _BitArray: List of [Byte]; // O(1) random access for mutations
        _FilterSize: Integer;
        _ByteSize: Integer;
        _HashCount: Integer;
        _IsInitialized: Boolean;
        _NotInitializedErr: Label 'Bloom filter is not initialized. Call Initialize first. This is a programming bug.', Locked = true;
        _InvalidExpectedElementsErr: Label 'ExpectedElements must be greater than 0. Value: %1. This is a programming bug.', Locked = true;
        _InvalidFilterSizeErr: Label 'Bloom filter FilterSize must be >= 2, got %1. This is a programming bug.', Locked = true;
        _InvalidHashCountErr: Label 'Bloom filter HashCount must be >= 1, got %1. This is a programming bug.', Locked = true;
        _CorruptBlobErr: Label 'Bloom filter blob is corrupted: expected %1 bytes, got %2. This is a programming bug.', Locked = true;

    /// <summary>
    /// Initializes the bloom filter with optimal size for the expected number of elements.
    /// Uses a fixed false positive rate of 0.1% (0.001).
    /// </summary>
    /// <param name="ExpectedElements">Expected number of elements to be added to the filter.</param>
    procedure Initialize(ExpectedElements: Integer)
    var
        OptimalFilterLength: Integer;
        OptimalHashIterations: Integer;
        Ln2: Decimal;
        Ln2Squared: Decimal;
        Math: Codeunit "Math";
        i: Integer;
        FalsePositiveRate: Decimal;
    begin
        if ExpectedElements <= 0 then
            Error(_InvalidExpectedElementsErr, ExpectedElements);

        FalsePositiveRate := 0.001; // 0.1%

        //https://en.wikipedia.org/wiki/Bloom_filter#Optimal_number_of_hash_functions
        // e = false positive rate
        // m = length of filter (bits)
        // n = expected number of elements
        // k = optimal number of hash iterations

        Ln2 := Math.Log(2);
        Ln2Squared := Ln2 * Ln2;

        // m = -(n * ln(e)) / (ln(2)^2)
        OptimalFilterLength := Round(-(ExpectedElements * Math.Log(FalsePositiveRate)) / Ln2Squared, 1, '>');
        if OptimalFilterLength < 64 then
            OptimalFilterLength := 64;

        // k = (m/n) * ln(2)
        OptimalHashIterations := Round((OptimalFilterLength / ExpectedElements) * Ln2, 1, '=');
        if OptimalHashIterations < 1 then
            OptimalHashIterations := 1;

        _FilterSize := OptimalFilterLength;
        _ByteSize := (_FilterSize + 7) div 8; // Ceiling division to get number of bytes needed
        _HashCount := OptimalHashIterations;

        Clear(_BitArray);
        for i := 1 to _ByteSize do
            _BitArray.Add(0);

        _IsInitialized := true;
    end;

    /// <summary>
    /// Adds a key to the bloom filter.
    /// </summary>
    /// <param name="KeyValue">The text key to add.</param>
    procedure Add(KeyValue: Text)
    var
        Pos: BigInteger;
        Step: BigInteger;
        i: Integer;
        BitPosition: Integer;
    begin
        if not _IsInitialized then
            Error(_NotInitializedErr);

        InitHashState(KeyValue, Pos, Step);
        for i := 1 to _HashCount do begin
            BitPosition := GetNextHashPosition(Pos, Step);
            SetBit(BitPosition);
        end;
    end;

    local procedure SetBit(BitPosition: Integer)
    var
        ByteIndex: Integer;
        BitOffset: Integer;
        ByteVal: Byte;
        ByteValInt: Integer;
        BitMask: Integer;
    begin
        ByteIndex := (BitPosition - 1) div 8 + 1;
        BitOffset := (BitPosition - 1) mod 8;
        BitMask := Power(2, BitOffset);

        ByteVal := _BitArray.Get(ByteIndex);
        ByteValInt := ByteVal;

        if (ByteValInt div BitMask) mod 2 = 1 then
            exit;

        ByteValInt := ByteValInt + BitMask;
        _BitArray.Set(ByteIndex, ByteValInt);
    end;

    /// <summary>
    /// Exports the filter state for persistence (e.g., storing in database to share across sessions).
    /// </summary>
    /// <param name="TempBlobOut">Returns the blob containing the filter's bit array.</param>
    /// <param name="FilterSize">Returns the size of the filter in bits.</param>
    /// <param name="HashCount">Returns the number of hash functions used.</param>
    procedure GetFilter(var TempBlobOut: Codeunit "Temp Blob"; var FilterSize: Integer; var HashCount: Integer)
    var
        OutStr: OutStream;
        ByteVal: Byte;
        i: Integer;
    begin
        Clear(TempBlobOut);
        TempBlobOut.CreateOutStream(OutStr);
        for i := 1 to _BitArray.Count() do begin
            ByteVal := _BitArray.Get(i);
            OutStr.Write(ByteVal, 1);
        end;
        FilterSize := _FilterSize;
        HashCount := _HashCount;
    end;

    /// <summary>
    /// Imports a previously exported filter state (e.g., loaded from database to share across sessions).
    /// Call this instead of Initialize when restoring a persisted filter.
    /// </summary>
    /// <param name="TempBlobIn">The blob containing the filter's bit array.</param>
    /// <param name="FilterSize">The size of the filter in bits.</param>
    /// <param name="HashCount">The number of hash functions used.</param>
    procedure SetFilter(TempBlobIn: Codeunit "Temp Blob"; FilterSize: Integer; HashCount: Integer)
    var
        InStr: InStream;
        ByteVal: Byte;
    begin
        // Validate up front: schema drift, truncated blobs or a manual cache wipe would otherwise
        // corrupt the filter silently and surface as a cryptic mod-by-zero or out-of-bounds at first use.
        if FilterSize < 2 then
            Error(_InvalidFilterSizeErr, FilterSize);
        if HashCount < 1 then
            Error(_InvalidHashCountErr, HashCount);

        _IsInitialized := false;

        _FilterSize := FilterSize;
        _ByteSize := (_FilterSize + 7) div 8;
        _HashCount := HashCount;

        Clear(_BitArray);
        TempBlobIn.CreateInStream(InStr);
        while InStr.Read(ByteVal, 1) > 0 do
            _BitArray.Add(ByteVal);

        if _BitArray.Count() <> _ByteSize then
            Error(_CorruptBlobErr, _ByteSize, _BitArray.Count());

        _IsInitialized := true;
    end;

    /// <summary>
    /// Checks if a key is possibly in the filter.
    /// Returns false = definitely not in set (trustworthy).
    /// Returns true = possibly in set (may be false positive, verify with actual lookup).
    /// </summary>
    /// <param name="KeyValue">The text key to check.</param>
    /// <returns>True if possibly present, false if definitely not present.</returns>
    procedure MayContain(KeyValue: Text): Boolean
    var
        Pos: BigInteger;
        Step: BigInteger;
        i: Integer;
        BitPosition: Integer;
    begin
        if not _IsInitialized then
            Error(_NotInitializedErr);

        InitHashState(KeyValue, Pos, Step);

        for i := 1 to _HashCount do begin
            BitPosition := GetNextHashPosition(Pos, Step);

            if not GetBit(BitPosition) then
                exit(false);
        end;

        exit(true);
    end;

    local procedure GetBit(BitPosition: Integer): Boolean
    var
        ByteIndex: Integer;
        BitOffset: Integer;
        ByteVal: Byte;
        ByteValInt: Integer;
        BitMask: Integer;
    begin
        ByteIndex := (BitPosition - 1) div 8 + 1;
        BitOffset := (BitPosition - 1) mod 8;
        BitMask := Power(2, BitOffset);

        ByteVal := _BitArray.Get(ByteIndex);
        ByteValInt := ByteVal;

        exit((ByteValInt div BitMask) mod 2 = 1);
    end;

    local procedure InitHashState(KeyValue: Text; var Pos: BigInteger; var Step: BigInteger)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        HashText: Text;
        Hash1: BigInteger;
        Hash2: BigInteger;
        FilterSizeBigInt: BigInteger;
    begin
        // MD5 = 32 hex chars = 128 bits. Use 15 hex chars (60 bits) per hash to avoid BigInteger overflow (>63 bits) in later calculations.
        // We use MD5 over SHA because it has enough bits, is faster to calculate and we are assuming non adversarial data.
        HashText := CryptographyManagement.GenerateHash(KeyValue, HashAlgorithmType::MD5);
        Hash1 := HexToPositiveBigInteger(CopyStr(HashText, 1, 15));
        Hash2 := HexToPositiveBigInteger(CopyStr(HashText, 16, 15));

        FilterSizeBigInt := _FilterSize;

        Pos := Hash1 mod FilterSizeBigInt;

        // Step is in [1, M-1]. The double-hashing orbit is M / gcd(Step, M); short orbits cause duplicate
        // bit positions for a single key, which weakens the filter.
        // - For even M: pick Step uniformly from odd values so gcd(Step, M) never has a guaranteed factor 2.
        //   When M is a power of 2 this also guarantees a full M-length orbit.
        // - For odd M:  parity is irrelevant; any value in [1, M-1] is fine.
        if (FilterSizeBigInt mod 2) = 0 then
            Step := (Hash2 mod (FilterSizeBigInt div 2)) * 2 + 1
        else
            Step := Hash2 mod (FilterSizeBigInt - 1) + 1;
    end;

    local procedure GetNextHashPosition(var Pos: BigInteger; Step: BigInteger): Integer
    var
        FilterSizeBigInt: BigInteger;
        Position: Integer;
    begin
        // https://en.wikipedia.org/wiki/Double_hashing
        FilterSizeBigInt := _FilterSize;
        Position := Pos + 1;
        Pos := AddMod(Pos, Step, FilterSizeBigInt);
        exit(Position);
    end;

    local procedure HexToPositiveBigInteger(HexString: Text): BigInteger
    var
        Result: BigInteger;
        DigitValue: BigInteger;
        Sixteen: BigInteger;
        i: Integer;
        C: Char;
    begin
        HexString := UpperCase(HexString);
        Result := 0;
        Sixteen := 16;

        for i := 1 to StrLen(HexString) do begin
            C := HexString[i];
            case C of
                '0' .. '9':
                    DigitValue := C - 48;
                'A' .. 'F':
                    DigitValue := C - 55;
                else
                    DigitValue := 0;
            end;
            Result := (Result * Sixteen) + DigitValue;
        end;

        exit(Result);
    end;

    local procedure AddMod(A: BigInteger; B: BigInteger; M: BigInteger): BigInteger
    begin
        // Overflow-safe (A + B) mod M
        // Precondition: 0 <= A < M, 0 <= B < M
        // If A + B would overflow or >= M, compute without overflow:
        //   if A >= M - B then result = A - (M - B) = A + B - M
        //   else result = A + B
        if A >= (M - B) then
            exit(A - (M - B))
        else
            exit(A + B);
    end;

    procedure GetInitialized(): Boolean
    begin
        exit(_IsInitialized);
    end;
}
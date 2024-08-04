-- 
-- function composes a crash address based on address properties
--
CREATE OR REPLACE FUNCTION build_address(
    block_num TEXT,
    street_pfx TEXT,
    street_name TEXT,
    street_sfx TEXT
)
RETURNS TEXT AS $$
DECLARE
    address text;
BEGIN
    -- Concat each address part only if it's not bull and not an empty string
    IF block_num IS NOT NULL AND block_num <> '' THEN
        address := block_num || ' ';
    END IF;
    
    IF street_pfx IS NOT NULL AND street_pfx <> '' THEN
        address := address || street_pfx || ' ';
    END IF;
    
    IF street_name IS NOT NULL AND street_name <> '' THEN
        address := address || street_name || ' ';
    END IF;
    
    IF street_sfx IS NOT NULL AND street_sfx <> '' THEN
        address := address || street_sfx || ' ';
    END IF;
    
    -- Trim the final address to remove any trailing space
    RETURN trim(address);
END;
$$ LANGUAGE plpgsql;

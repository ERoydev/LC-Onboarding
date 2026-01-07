import { useState, useEffect, useMemo } from 'react';
import TokenData from '../intefaces/TokenData';
import { getNFTsByOwner, getTokenURLFromTokenId } from '../services/nftContractService';

export function useFetchTokenUrls(account: string | null) {
    
    const [loading, setLoading] = useState(true);
    const [tokensData, setTokensData] = useState<TokenData[]>([]);
    const [nftIds, setNftIds] = useState<number[]>([]); // State to store NFT IDs

    const setTokenIdsOwned = async () => {
        if (!account) {
            // console.error('No account connected');
            return [];
        }
        const tokenIds = await getNFTsByOwner(account);
        setNftIds(tokenIds); // Update state with fetched NFT IDs
        return tokenIds; // Return the fetched token IDs
    };

    const removeToken = (tokenId: number) => {
        setTokensData((prevTokens) => prevTokens.filter((token) => token.tokenId !== tokenId));
    }

    const fetchTokenURLs = async (tokenIds: number[]) => {
        setLoading(true);
        const allTokenData: TokenData[] = [];

        for (let i = 0; i < tokenIds.length; i++) {
            const tokenURL = await getTokenURLFromTokenId(tokenIds[i]);

            const res = await fetch(tokenURL);
            if (!res.ok) {
                console.error("Error fetching token URL:", res.statusText);
                continue;
            }

            const tokenData: TokenData = await res.json();
            tokenData.tokenId = tokenIds[i]; // Use the correct tokenId from the fetched list
            allTokenData.push(tokenData);
        }
        setTokensData(allTokenData);
        setLoading(false);
    };

    const fetchData = async () => {
        const tokenIds = await setTokenIdsOwned(); // Wait for token IDs to be fetched
        await fetchTokenURLs(tokenIds);
        setLoading(false);
    };

    useEffect(() => {
        fetchData();
    }, [account]); // Re-run when the account changes

    // Use useMemo to memoize the tokensData and avoid unnecessary re-fetching
    // Not tested how it behaves in reality, but it works
    const memoizedTokensData = useMemo(() => tokensData, [tokensData]);

    return { loading, tokensData: memoizedTokensData, removeToken, refetchData: fetchData };
}
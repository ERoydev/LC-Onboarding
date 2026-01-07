// useFetch.ts
import { useState, useEffect } from 'react';
import { fetchActiveAuctions, fetchNonActiveAuctions } from '../services/AuctionService';
import { getTokenURLFromTokenId } from '../services/nftContractService';

interface ActiveAuctions {
    seller: string;
    startPrice: string;
    endTime: number;
    highestBid: string;
    auctionId: number;
    highestBidder: string;
    imageurl: string;
    nftName: string;
    nftTokenId: number;
}

// TODO: This is not the best way to do this, but it works for now.
// We should consider using a more efficient way to fetch and store token metadata.
export function useFetchAuctions(isActive: boolean = true) {
    const [loading, setLoading] = useState(true);
    const [auctions, setAuctions] = useState<ActiveAuctions[]>([]);

    const fetchAllAuctions = async () => {
        setLoading(true);

        const fetchedAuctions = isActive ? await fetchActiveAuctions() : await fetchNonActiveAuctions();

        for (let i = 0; i < fetchedAuctions.length; i++) {
            const tokenId = Number(fetchedAuctions[i].nftTokenId);
            const tokenMetadata = await getTokenURLFromTokenId(tokenId);
            try {
                const res = await fetch(tokenMetadata);
                if (!res.ok) {
                    console.error("Error fetching token URL:", res.statusText);
                    continue;
                }
                const tokenData = await res.json();
                fetchedAuctions[i].imageurl = tokenData.image;
                fetchedAuctions[i].nftName = tokenData.name;
                fetchedAuctions[i].seller = fetchedAuctions[i].seller.toLocaleLowerCase();
            } catch (error) {
                console.error("Error fetching token metadata:", error);
            }
        }
        setAuctions(fetchedAuctions);
        setLoading(false);
    } 

    useEffect(() => {
        fetchAllAuctions();
    }, []);

    return {loading, auctions, refetch: fetchAllAuctions};
}

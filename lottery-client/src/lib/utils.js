export function shortenAddress(address, startLength = 6, endLength = 4) {
    if (!address || address.length < startLength + endLength) {
        return address;
    }
    return `${address.slice(0, startLength)}...${address.slice(-endLength)}`;
}

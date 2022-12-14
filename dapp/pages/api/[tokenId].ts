// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from 'next'

// type Data = {
//   name: string
//   description: string
//   image: any
// }

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
 // get the tokenId from the query params
    const tokenId = req.query.tokenId;
    const name = "Crypto Dev #" + tokenId;
    const description: string ="Crypto Dev is a collection of developers in crypto";
    // As all the images are uploaded on github, we can extract the images from github directly.
    const image_url =
      `https://raw.githubusercontent.com/LearnWeb3DAO/NFT-Collection/main/my-app/public/cryptodevs/${Number(tokenId) - 1}.svg`;
    // The api is sending back metadata for a Crypto Dev
    // To make our collection compatible with Opensea, we need to follow some Metadata standards
    // when sending back the response from the api
    // More info can be found here: https://docs.opensea.io/docs/metadata-standards
    res.status(200).json({
      name: name,
      description: description ,
      image: image_url + tokenId + ".svg",
    })
}

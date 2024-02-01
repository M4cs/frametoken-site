import type { Metadata } from "next";
import { Inter, Montserrat } from "next/font/google";
import "./globals.css";
import { getFrameMetadata } from "@coinbase/onchainkit";

const montserrat = Montserrat({ subsets: ["latin"] });

const BASE_URL = process.env.BASE_URL;

const frameMetadata = getFrameMetadata({
  buttons: [
    {
      label: 'Click to claim your airdrop!',
      action: 'post'
    },
    {
      label: 'Donate to help fund LP',
      action: 'post_redirect'
    }
  ],
  post_url: BASE_URL + '/api/frame',
  image: BASE_URL + '/images/DefaultFrame.png'
});

export const metadata: Metadata = {
  title: "Frame Token | Claim Your Airdrop",
  description: "The first airdrop using Farcaster Frames!",
  openGraph: {
    title: "Frame Token | Claim Your Airdrop",
    description: "The first airdrop using Farcaster Frames!",
    images: [
      {
        url: BASE_URL + "/images/DefaultFrame.png",
        width: 900,
        height: 1600,
        alt: 'Frame Token',
      }
    ]
  },
  other: {
    ...frameMetadata
  }
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={montserrat.className}>
        {children}
      </body>
    </html>
  );
}

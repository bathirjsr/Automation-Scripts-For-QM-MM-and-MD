import asyncio
import websockets
import json
import MDAnalysis as mda
import sys

# The Extension Host will pass these as command-line arguments
PORT = int(sys.argv[1])
TOPOLOGY_PATH = sys.argv[2]
TRAJECTORY_PATH = sys.argv[3]

# Load the universe
u = mda.Universe(TOPOLOGY_PATH, TRAJECTORY_PATH)


async def handle_client(websocket, path):
    # Send initial metadata (number of frames)
    await websocket.send(json.dumps({
        "type": "metadata",
        "num_frames": len(u.trajectory)
    }))

    async for message in websocket:
        data = json.loads(message)
        if data["type"] == "request_frame":
            frame_idx = data["frame"]

            # Jump to the requested frame
            u.trajectory[frame_idx]

            # Extract coordinates (N x 3 array)
            coords = u.atoms.positions.tolist()

            # Send coordinates back to the Webview
            await websocket.send(json.dumps({
                "type": "frame_data",
                "frame": frame_idx,
                "coordinates": coords
            }))

start_server = websockets.serve(handle_client, "localhost", PORT)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

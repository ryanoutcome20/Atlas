# Atlas 🌐

## Overview

Atlas is a lightweight, modular networking library designed for Garry's Mod, offering a more dynamic and feature-rich networking system. It enhances networking by overcoming the built-in limitations of Garry's Mod. Features include:
  * **Chunk Based Networking** - Eliminates bandwidth restrictions by efficiently handling large data transfers.
  * **Dynamic Hooking System** – Allows multiple functions to be hooked to the same networking string for greater flexibility.
  * **Single Networking String** – Eliminates the need for `AddNetworkString`, cleaning up existing code bases.
  * **Modular Architecture** – Drag-and-drop simplicity for easy integration.
  * **Integration** – Designed to work seamlessly with existing projects without networking collisions, unlike other libraries.
  * **Client and Server** - Fully compatible with both clientside and serverside communication, utilizing two-way communication via port-based listeners.
  * **Hash Verification** - Provides a fully implemented a SHA-256 hash system to verify the authenticity and wholeness of the provided data.

## Installation

You can install Atlas via the [releases](https://github.com/ryanoutcome20/Atlas/releases/) or manually by following these steps:

1. Cloning the repository:
   ```bash
   git clone https://github.com/ryanoutcome20/atlas.git
   ```
2. Drag and drop the folder into your Garry’s Mod addons directory:
   ```
   Steam/steamapps/common/GarrysMod/garrysmod/addons/
   ```
3. Implementing into existing projects through the **API**.

## Documentation

You can find the full Quickstart Guide [here](./docs/quickstart.md).

## Additional Information

### Contributing

Contributions are welcome! If you find a bug or want to add a new feature, feel free to fork the repository and submit a pull request.

### License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](./LICENSE) file for more details.

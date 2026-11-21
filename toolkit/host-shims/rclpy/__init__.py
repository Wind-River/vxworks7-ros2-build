# Host-side rclpy STUB for the ROS 2 VxWorks SDK toolkit.
#
# The real rclpy in export/root is built for the TARGET (VxWorks) and its C
# extension (_rclpy_pybind11) cannot load on the build host. The host `ros2`
# CLI only needs to *import* rclpy (ros2cli/cli.py does
# `from rclpy.executors import ExternalShutdownException`), so this stub
# satisfies that import for host-only verbs like `ros2 pkg create`.
#
# It intentionally does NOT provide a working runtime: any attempt to actually
# use rclpy (init/create_node/spin) on the host raises, since ROS 2 runtime is
# for the VxWorks target, not the host.

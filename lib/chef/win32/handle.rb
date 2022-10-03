#
# Author:: John Keiser (<jkeiser@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "api/process"
require_relative "api/psapi"
require_relative "api/system"
require_relative "error"

require "chef/mixin/powershell_exec"

class Chef
  module ReservedNames::Win32
    class Handle
      extend Chef::ReservedNames::Win32::API::Process

      # See http://msdn.microsoft.com/en-us/library/windows/desktop/ms683179(v=vs.85).aspx
      # The handle value returned by the GetCurrentProcess function is the pseudo handle (HANDLE)-1 (which is 0xFFFFFFFF)
      CURRENT_PROCESS_HANDLE = 4294967295

      def initialize(handle)
        @handle = handle
        @is_2012 ||= get_proc_os
        ObjectSpace.define_finalizer(self, Handle.close_handle_finalizer(handle))
      end

      attr_reader :handle

      def get_proc_os
        os = powershell_exec("(Get-CimInstance win32_operatingsystem).Caption").result
        os.match(/2012/) && !os.match(/R2/) ? true : false
      end

      def self.close_handle_finalizer(handle)
        # According to http://msdn.microsoft.com/en-us/library/windows/desktop/ms683179(v=vs.85).aspx, it is not necessary
        # to close the pseudo handle returned by the GetCurrentProcess function.  The docs also say that it doesn't hurt to call
        # CloseHandle on it. However, doing so from inside of Ruby always seems to produce an invalid handle error.
        proc { close_handle(handle) unless handle == CURRENT_PROCESS_HANDLE } unless @is_2012
      end

      def self.close_handle(handle)
        unless CloseHandle(handle)
          Chef::ReservedNames::Win32::Error.raise!
        end
      end

    end
  end
end
